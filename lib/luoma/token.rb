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

  TOKEN_KIND_MAP = {
    token_add: "ADD",
    token_and: "AND",
    token_arrow: "ARROW",
    token_assign: "ASSIGN",
    token_colon: "COLON",
    token_comma: "COMMA",
    token_comment: "COMMENT",
    token_comment_end: "COMMENT_END",
    token_comment_start: "COMMENT_START",
    token_contains: "CONTAINS",
    token_div: "DIV",
    token_dot: "DOT",
    token_double_dot: "DOUBLE_DOT",
    token_double_escaped: "DOUBLE_ESCAPED",
    token_double_quote: "DOUBLE_QUOTE",
    token_double_quoted: "DOUBLE_QUOTED",
    token_else: "ELSE",
    token_eq: "EQ",
    token_false: "FALSE",
    token_float: "FLOAT",
    token_ge: "GE",
    token_gt: "GT",
    token_ident: "IDENT",
    token_if: "IF",
    token_in: "IN",
    token_int: "INT",
    token_interpolation_end: "INTERPOLATION_END",
    token_interpolation_start: "INTERPOLATION_START",
    token_lbrace: "LBRACE",
    token_lbracket: "LBRACKET",
    token_le: "LE",
    token_lparen: "LPAREN",
    token_lt: "LT",
    token_mod: "MOD",
    token_mul: "MUL",
    token_ne: "NE",
    token_nil: "NIL",
    token_not: "NOT",
    token_null: "NULL",
    token_or_else: "OR_ELSE",
    token_or: "OR",
    token_out_end: "OUT_END",
    token_out_start: "OUT_START",
    token_pipe: "PIPE",
    token_question: "QUESTION",
    token_rbrace: "RBRACE",
    token_rbracket: "RBRACKET",
    token_rparen: "RPAREN",
    token_single_escaped: "SINGLE_ESCAPED",
    token_single_quote: "SINGLE_QUOTE",
    token_single_quoted: "SINGLE_QUOTED",
    token_sub: "SUB",
    token_tag_end: "TAG_END",
    token_tag_name: "TAG_NAME",
    token_tag_start: "TAG_START",
    token_text: "TEXT",
    token_triple_dot: "TRIPLE_DOT",
    token_true: "TRUE",
    token_wc: "WC",
    token_eoi: "EOI",
    token_unknown: "UNKNOWN",
    token_hash: "HASH",
    token_span: "SPAN",
    token_blank: "BLANK",
    token_empty: "EMPTY",
    token_for: "FOR",
    token_with: "WITH"
  }.freeze #: Hash[t_token_kind, String]
end
