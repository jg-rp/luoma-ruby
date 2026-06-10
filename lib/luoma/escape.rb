# frozen_string_literal: true

module Luoma
  RE_ESCAPE = /["&'<>`]/

  ESCAPE_MAP = {
    '"' => "&#34;",
    "&" => "&amp;",
    "'" => "&#39;",
    "<" => "&lt;",
    ">" => "&gt;",
    "`" => "&#96;"
  }.freeze #: Hash[String, String]

  RE_UNESCAPE = /&(#34|amp|#39|lt|gt|#96);/i

  UNESCAPE_MAP = {
    "&#34;": '"',
    "&amp;" => "&",
    "&#39;" => "'",
    "&lt;" => "<",
    "&gt;" => ">",
    "&#96;" => "`"
  }.freeze #: Hash[String, String]

  #: (String) -> String
  def self.escape(s)
    s.gsub(RE_ESCAPE) { |m| ESCAPE_MAP[m] }
  end

  #: (String) -> String
  def self.unescape(s)
    s.gsub(RE_UNESCAPE) { |m| UNESCAPE_MAP[m] }
  end
end
