# frozen_string_literal: true

module Luoma
  # If _strict_ is false, fill and/or remove arguments from _args_ and _kwargs_
  # to match _method_ parameters. Otherwise raise an error if the arguments would
  # raise an ArgumentError.
  #
  #: (::Method, Array[untyped], Hash[Symbol, untyped], ?strict: bool) -> [Array[untyped], Hash[Symbol, untyped]]
  def self.normalize_arguments(method, args, kwargs, strict: false)
    params = method.parameters

    # The first two required arguments are always `context` and `left`, neither
    # of which are included in `args`.
    required_positional = params.count { |type, _name| type == :req } - 2
    optional_positional = params.count { |type, _name| type == :opt }
    has_rest = params.any? { |type, _name| type == :rest }

    required_keys = params.select { |type, _name| type == :keyreq }.map(&:last) # rubocop:disable Style/HashSlice
    optional_keys = params.select { |type, _name| type == :key }.map(&:last) # rubocop:disable Style/HashSlice
    has_keyrest = params.any? { |type, _name| type == :keyrest }

    if strict
      validate_arguments(
        method,
        args,
        kwargs,
        required_positional: required_positional,
        optional_positional: optional_positional,
        has_rest: has_rest,
        required_keys: required_keys,
        optional_keys: optional_keys,
        has_keyrest: has_keyrest
      )
    end

    unless has_rest
      max = required_positional + optional_positional
      args = args.take(max)
    end

    args.fill(:nothing, args.length...required_positional)

    unless has_keyrest
      allowed_keys = required_keys + optional_keys
      kwargs.select! { |key, _value| allowed_keys.include?(key) }
    end

    required_keys.each do |key|
      kwargs[key] = :nothing unless kwargs.key?(key)
    end

    [args, kwargs]
  end

  def self.validate_arguments(
    method, args, kwargs,
    required_positional:,
    optional_positional:,
    has_rest:,
    required_keys:,
    optional_keys:,
    has_keyrest:
  )
    if args.length < required_positional
      raise ArgumentError,
            "wrong number of arguments (given #{args.length}, expected #{required_positional}+) for #{method.name}"
    end

    unless has_rest
      max_positional = required_positional + optional_positional
      if args.length > max_positional
        raise ArgumentError,
              "wrong number of arguments (given #{args.length}, expected #{required_positional}..#{max_positional}) for #{method.name}"
      end
    end

    unless has_keyrest
      allowed_keys = required_keys + optional_keys
      unknown_keys = kwargs.keys - allowed_keys
      unless unknown_keys.empty?
        raise ArgumentError,
              "unknown keyword#{"s" if unknown_keys.length > 1}: #{unknown_keys.map(&:inspect).join(", ")} for #{method.name}"
      end
    end

    missing_keys = required_keys.reject { |key| kwargs.key?(key) }
    unless missing_keys.empty?
      raise ArgumentError,
            "missing keyword#{"s" if missing_keys.length > 1}: #{missing_keys.map(&:inspect).join(", ")} for #{method.name}"
    end
  end
end
