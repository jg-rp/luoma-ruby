# frozen_string_literal: true

require "base64"
require "cgi/escape"

module Luoma
  module Filters
    # Return _left_ concatenated with _right_.
    # Coerce _left_ and _right_ to strings if they aren't strings already.
    def self.append(context, left, right)
      context.to_string(left) + context.to_string(right)
    end

    # Return _left_ with the first character in uppercase and the rest lowercase.
    # Coerce _left_ to a string if it is not one already.
    def self.capitalize(context, left)
      context.to_string(left).capitalize
    end

    # Return _left_ with all characters converted to lowercase.
    # Coerce _left_ to a string if it is not one already.
    def self.downcase(context, left)
      context.to_string(left).downcase
    end

    # Return _left_ with all characters converted to uppercase.
    # Coerce _left_ to a string if it is not one already.
    def self.upcase(context, left)
      context.to_string(left).upcase
    end

    # Return _left_ with special HTML characters replaced with their HTML-safe escape sequences.
    # Coerce _left_ to a string if it is not one already.
    def self.escape(context, left)
      CGI.escape_html(context.to_string(left)) unless left.nil?
    end

    # Return _left_ with special HTML characters replaced with their HTML-safe escape sequences.
    # Coerce _left_ to a string if it is not one already.
    #
    # It is safe to use `escape_once` on string values that already contain HTML-escape sequences.
    def self.escape_once(context, left)
      CGI.escape_html(CGI.unescape_html(context.to_string(left)))
    end

    # Return _left_ with leading whitespace removed.
    # Coerce _left_ to a string if it is not one already.
    def self.lstrip(context, left)
      context.to_string(left).lstrip
    end

    # Return _left_ with trailing whitespace removed.
    # Coerce _left_ to a string if it is not one already.
    def self.rstrip(context, left)
      context.to_string(left).rstrip
    end

    # Return _left_ with leading and trailing whitespace removed.
    # Coerce _left_ to a string if it is not one already.
    def self.strip(context, left)
      context.to_string(left).strip
    end

    # Return _left_ with LF or CRLF replaced with `<br />\n`.
    def self.newline_to_br(context, left)
      context.to_string(left).gsub(/\r?\n/, "<br />\n")
    end

    # Return _right_ concatenated with _left_.
    # Coerce _left_ and _right_ to strings if they aren't strings already.
    def self.prepend_(context, left, right)
      context.to_string(right) + context.to_string(left)
    end

    # Return _left_ with all occurrences of _pattern_ replaced with _replacement_.
    # All arguments are coerced to strings if they aren't strings already.
    def self.replace(context, left, pattern, replacement = "")
      context.to_string(left).gsub(context.to_string(pattern), context.to_string(replacement))
    end

    # Return _left_ with the first occurrence of _pattern_ replaced with _replacement_.
    # All arguments are coerced to strings if they aren't strings already.
    def self.replace_first(context, left, pattern, replacement = "")
      context.to_string(left).sub(context.to_string(pattern), context.to_string(replacement))
    end

    # Return _left_ with the last occurrence of _pattern_ replaced with _replacement_.
    # All arguments are coerced to strings if they aren't strings already.
    def self.replace_last(context, left, pattern, replacement)
      return left + replacement if context.nothing?(pattern)

      head, match, tail = context.to_string(left).rpartition(context.to_string(pattern))
      return left if match.empty?

      head + context.to_string(replacement) + tail
    end

    # Return _left_ with all occurrences of _pattern_ removed.
    # All arguments are coerced to strings if they aren't strings already.
    def self.remove(context, left, pattern)
      context.to_string(left).gsub(context.to_string(pattern), context.to_string(""))
    end

    # Return _left_ with the first occurrence of _pattern_ removed.
    # All arguments are coerced to strings if they aren't strings already.
    def self.remove_first(context, left, pattern)
      context.to_string(left).sub(context.to_string(pattern), context.to_string(""))
    end

    # Return _left_ with the last occurrence of _pattern_ removed.
    # All arguments are coerced to strings if they aren't strings already.
    def self.remove_last(context, left, pattern)
      return left if context.nothing?(pattern)

      head, match, tail = context.to_string(left).rpartition(context.to_string(pattern))
      return left if match.empty?

      head + tail
    end

    # Split _left_ on every occurrence of _pattern_.
    def self.split(context, left, pattern)
      context.to_string(left).split(context.to_string(pattern))
    end

    RE_HTML_BLOCKS = Regexp.union(
      %r{<script.*?</script>}m,
      /<!--.*?-->/m,
      %r{<style.*?</style>}m
    )

    RE_HTML_TAGS = /<.*?>/m

    # Return _left_ with HTML tags removed.
    def self.strip_html(context, left)
      context.to_string(left).gsub(RE_HTML_BLOCKS, "").gsub(RE_HTML_TAGS, "")
    end

    # Return _left_ with CR and LF removed.
    def self.strip_newlines(context, left)
      context.to_string(left).gsub(/\r?\n/, "")
    end

    def self.truncate(context, left, max_length = 50, ellipsis = "...")
      return if left.nil? || context.nothing?(left)

      left = context.to_string(left)
      max_length = context.to_i(max_length)
      return left if left.length <= max_length

      ellipsis = context.to_string(ellipsis)
      return ellipsis[0, max_length] if ellipsis.length >= max_length

      "#{left[0...(max_length - ellipsis.length)]}#{ellipsis}"
    end

    def self.truncatewords(context, left, max_words = 15, ellipsis = "...")
      return if left.nil? || context.nothing?(left)

      left = context.to_string(left)
      max_words = context.to_i(max_words).clamp(1, 10_000)
      words = left.split(" ", max_words + 1)
      return left if words.length <= max_words

      ellipsis = context.to_string(ellipsis)
      words.pop
      "#{words.join(" ")}#{ellipsis}"
    end

    def self.url_encode(context, left)
      CGI.escape(context.to_string(left)) unless left.nil? || context.nothing?(left)
    end

    def self.url_decode(context, left)
      return if left.nil? || context.nothing?(left)

      decoded = CGI.unescape(context.to_string(left))
      raise context.argument_error("invalid byte sequence") unless decoded.valid_encoding?

      decoded
    end

    def self.base64_encode(context, left)
      Base64.strict_encode64(context.to_string(left)).force_encoding(Encoding::UTF_8)
    end

    def self.base64_decode(context, left)
      decoded = Base64.strict_decode64(context.to_string(left)).force_encoding(Encoding::UTF_8)
      decoded if decoded.valid_encoding?
    end

    def self.base64_url_safe_encode(context, left)
      Base64.urlsafe_encode64(context.to_string(left)).force_encoding(Encoding::UTF_8)
    end

    def self.base64_url_safe_decode(context, left)
      decoded = Base64.urlsafe_decode64(context.to_string(left)).force_encoding(Encoding::UTF_8)
      decoded if decoded.valid_encoding?
    end

    def self.squish(context, left)
      context.to_string(left).strip.gsub(/\s+/, " ") unless left.nil?
    end
  end
end
