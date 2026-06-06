# frozen_string_literal: true

module Luoma
  #: (t_token, String) -> String
  def self.get_token_value(token, source)
    source.byteslice(token[:start]..token[:stop]) || raise
  end

  # Return a new token spanning `start` and `stop`.
  #: (t_token, t_token) -> t_token
  def self.span(start, stop)
    { kind: :token_span, start: start[:start], stop: stop[:stop] }
  end
end
