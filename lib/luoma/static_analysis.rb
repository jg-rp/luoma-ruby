# frozen_string_literal: true

module Luoma
  # Template static analysis.
  module StaticAnalysis
    # The location of a variable, tag or filter.
    class Location
      attr_reader :template, :token

      #: (Template, t_token) -> void
      def initialize(template, token)
        @template = template
        @token = token
      end

      # Return the line and column number of the given index.
      #
      #: (Integer) -> [Integer, Integer]
      def line_col(index)
        lines = @template.lines
        cumulative_length = 0
        target_line_index = -1

        lines.each_with_index do |line, i|
          cumulative_length += line.length

          if index < cumulative_length
            target_line_index = i
            break
          end
        end

        raise LuomaError.new("index out of bounds") if target_line_index == -1

        line_number = target_line_index + 1
        line = lines[target_line_index]
        column_number = index - (cumulative_length - line.length)
        [line_number, column_number]
      end

      def ==(other)
        self.class == other.class &&
          @template.name == other.template.name &&
          @token == other.token
      end

      alias eql? ==

      def hash
        [@template.name, @token].hash
      end

      # Return the line and column number for the start and end index spanning
      # this location.
      #
      #: () -> [[Integer, Integer],[Integer, Integer]]
      def span
        [line_col(@token[1]), line_col(@token[2])]
      end

      # Return the substring spanning this location.
      #
      #: () -> String
      def value
        Luoma.get_token_value(@token, @template.source)
      end
    end

    # A variable as a sequence of segments and its location.
    class StaticVariable
      attr_reader :segments, :location

      RE_PROPERTY = /\A[\u0080-\uFFFFa-zA-Z_][\u0080-\uFFFFa-zA-Z0-9_-]*\Z/

      def initialize(segments, location)
        @segments = segments
        @location = location
      end

      def to_s
        segments_to_s(@segments)
      end

      def ==(other)
        self.class == other.class &&
          @segments == other.segments
      end

      alias eql? ==

      def hash
        @segments.hash
      end

      #: () -> String
      def root
        segment = @segments.first || ""
        segment.is_a?(Array) ? segments_to_s(segment) : segment.to_s
      end

      protected

      def segments_to_s(segments)
        head, *rest = segments

        head.to_s + rest.map do |segment|
          case segment
          when Array
            "[#{segments_to_s(segment)}]"
          when String
            if segment.match?(RE_PROPERTY) || segment.end_with?("?")
              ".#{segment}"
            else
              "[#{segment.inspect}]"
            end
          else
            "[#{segment}]"
          end
        end.join
      end
    end

    # Helper to manage variable scope during static analysis.
    class StaticScope
      #: (Set[String]) -> void
      def initialize(globals)
        @stack = [globals] #: Array[Set[String]]
      end

      def include?(key)
        @stack.any? { |scope| scope.include?(key) }
      end

      def push(scope)
        @stack << scope
        self
      end

      def pop
        @stack.pop
      end

      def add(name)
        @stack.first.add(name)
      end
    end

    # Helper to group variables by their root segment during static analysis.
    class VariableMap
      attr_reader :data

      def initialize
        @data = {}
      end

      def [](var)
        key = var.root
        @data[key] = [] unless @data.include?(key)
        @data[key]
      end

      def add(var)
        send(:[], var) << var
      end

      #: () -> Hash[String, Array[_Var]]
      def to_h
        result = {} #: Hash[String, Array[untyped]]

        @data.each do |k, v|
          a = [] #: Array[untyped]

          v.each do |sv|
            start_line, start_column, end_line, end_column = sv.location.span

            a << {
              segments: sv.segments,
              path: sv.to_s,
              start_index: sv.location.token[1],
              end_index: sv.location.token[2],
              start_line: start_line,
              start_column: start_column,
              end_line: end_line,
              end_column: end_column,
              value: sv.location.value,
              template_name: sv.location.template.name
            }
          end

          result[k] = a
        end

        result
      end
    end

    # The result of analyzing a template.
    class Result
      attr_reader :variables, :globals, :locals, :filters, :tags

      def initialize(variables, globals, locals, filters, tags)
        @variables = variables
        @globals = globals
        @locals = locals
        @filters = filters
        @tags = tags
      end

      def to_h
        {
          variables: @variables,
          globals: @globals,
          locals: @locals,
          filters: @filters,
          tags: @tags
        }
      end
    end

    def self.analyze(template, include_partials:)
      variables = VariableMap.new
      globals = VariableMap.new
      locals = VariableMap.new

      # @type var filters: Hash[String, Array[Location]]
      filters = Hash.new { |hash, key| hash[key] = [] }
      # @type var tags: Hash[String, Array[Location]]
      tags = Hash.new { |hash, key| hash[key] = [] }

      # @type var template_scope: Set[String]
      template_scope = Set[]
      root_scope = StaticScope.new(template_scope)
      static_context = Luoma::RenderContext.new(template)

      # Names of partial templates that have already been analyzed.
      # Keys are hashes of partial template name and its arguments. If we've
      # visited a template before but with different arguments, later visits
      # only record global variables so as not to double count locals, filters
      # and tags.
      seen = Hash.new { |hash, key| hash[key] = Set[] } #: Hash[String,Set[untyped]]

      # @type var visit: ^(Luoma::Markup, Luoma::Template, StaticScope, bool) -> void
      visit = lambda do |node, template, scope, just_globals|
        seen[template.name].add(nil) if !template.name.empty? && !just_globals

        # Update tags
        # Markup with empty `tag_name` is silenced.
        tags[node.tag_name] << Location.new(template, node.token) if !just_globals && !node.tag_name.empty?

        # Update variables from node.expressions
        node.expressions.each do |expr|
          if expr.is_a?(Luoma::Expression)
            analyze_variables(
              expr,
              template,
              scope,
              globals,
              just_globals ? VariableMap.new : variables,
              static_context
            )
          end

          next if just_globals

          # Update filters from expr
          extract_filters(expr, template, static_context).each do |name, span|
            filters[name] << span
          end
        end

        # Update template scope from node.template_scope
        node.template_scope.each do |name|
          scope.add(name.value)
          locals.add(StaticVariable.new([name.value], Location.new(template, name.token)))
        end

        # Set block scope before descending into child nodes.
        scope.push(node.block_scope.to_set(&:value))

        node.children(static_context).each do |child|
          visit.call(child, template, scope, just_globals)
        end

        scope.pop

        # Descend into partial templates?
        partial = include_partials && node.partial(static_context)
        if partial.is_a?(Luoma::Partial)
          name = partial.template.name
          just_globals_ = seen.include?(name)

          unless seen[name].include?(partial.key)
            seen[name].add(partial.key)

            partial_scope = if partial.scope_kind == :isolated
                              StaticScope.new(partial.in_scope.to_set(&:value))
                            else
                              root_scope.push(partial.in_scope.to_set(&:value))
                            end

            partial.template.nodes.each do |p_node|
              visit.call(p_node, partial.template, partial_scope, just_globals_) if p_node.is_a?(Luoma::Markup)
            end

            partial_scope.pop if partial.scope_kind == :isolated
          end
        end
      end

      template.nodes.each do |node|
        visit.call(node, template, root_scope, false) if node.is_a?(Luoma::Markup)
      end

      Result.new(
        variables.to_h,
        globals.to_h,
        locals.to_h,
        to_locations(filters),
        to_locations(tags)
      )
    end

    #: (Luoma::_Traversable, Luoma::Template, Luoma::RenderContext) -> Array[[String, Location]]
    def self.extract_filters(expression, template, static_context)
      filters = [] # : Array[[String, Location]]

      if expression.is_a?(Luoma::Filter) # steep:ignore
        filters << [expression.name.to_s, Location.new(template, expression.span)]
      end

      expression.children.each do |expr|
        filters.concat(extract_filters(expr, template, static_context))
      end

      filters
    end

    # (Luoma:_Traversable, Luoma::Template, StaticScope, VariableMap, VariableMap, RenderContext) -> void
    def self.analyze_variables(expression, template, scope, globals, variables, static_context)
      if expression.is_a?(Luoma::Variable) # steep:ignore
        token = if expression.segments.last.is_a?(Luoma::Predicate)
                  # Don't include a the trailing predicate.
                  if expression.segments.length > 1
                    Luoma.span(expression.root.span,
                               expression.segments[-2].span)
                  else
                    expression.root.span
                  end
                else
                  expression.span
                end

        var = StaticVariable.new(segments(expression, template), Location.new(template, token))

        variables.add(var)
        globals.add(var) unless scope.include?(expression.root.to_s)
      end

      # TODO: Handle lambda scoping

      expression.children.each do |expr|
        analyze_variables(
          expr,
          template,
          scope,
          globals,
          variables,
          static_context
        )
      end
    end

    #: (Luoma::Variable, Luoma::Template) -> Array[untyped]
    def self.segments(var, template)
      segments_ = [] #: Array[untyped]

      segments_ << if var.root.is_a?(Luoma::Variable)
                     segments(var.root, template)
                   else
                     var.root.value
                   end

      var.segments.each do |s|
        segments_ << if s.is_a?(Luoma::Variable)
                       segments(s, template)
                     elsif s.is_a?(Luoma::Predicate)
                       next
                     else
                       s.value
                     end
      end

      segments_
    end

    #: (Hash[String, Array[Location]]) -> Hash[String, Array[untyped]]
    def self.to_locations(map)
      result = {} #: Hash[String, Array[untyped]]

      map.each do |k, v|
        a = [] #: Array[untyped]

        v.each do |l|
          span = l.span
          a << {
            start_index: l.token[1],
            end_index: l.token[2],
            start_line: span.first.first,
            start_column: span.first.last,
            end_line: span.last.first,
            end_column: span.last.last,
            value: l.value,
            template_name: l.template.name
          }
        end

        result[k] = a
      end

      result
    end
  end
end
