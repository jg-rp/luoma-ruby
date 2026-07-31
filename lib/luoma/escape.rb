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

  ESCAPE_JS_MAP = {
    "\\" => "\\u005C",
    "'" => "\\u0027",
    "\"" => "\\u0022",
    ">" => "\\u003E",
    "<" => "\\u003C",
    "&" => "\\u0026",
    "=" => "\\u003D",
    "-" => "\\u002D",
    ";" => "\\u003B",
    "`" => "\\u0060",
    "\u2028" => "\\u2028",
    "\u2029" => "\\u2029",
    "\x00" => "\\u0000",
    "\x01" => "\\u0001",
    "\x02" => "\\u0002",
    "\x03" => "\\u0003",
    "\x04" => "\\u0004",
    "\x05" => "\\u0005",
    "\x06" => "\\u0006",
    "\x07" => "\\u0007",
    "\x08" => "\\u0008",
    "\t" => "\\u0009",
    "\n" => "\\u000A",
    "\x0b" => "\\u000B",
    "\x0c" => "\\u000C",
    "\r" => "\\u000D",
    "\x0e" => "\\u000E",
    "\x0f" => "\\u000F",
    "\x10" => "\\u0010",
    "\x11" => "\\u0011",
    "\x12" => "\\u0012",
    "\x13" => "\\u0013",
    "\x14" => "\\u0014",
    "\x15" => "\\u0015",
    "\x16" => "\\u0016",
    "\x17" => "\\u0017",
    "\x18" => "\\u0018",
    "\x19" => "\\u0019",
    "\x1a" => "\\u001A",
    "\x1b" => "\\u001B",
    "\x1c" => "\\u001C",
    "\x1d" => "\\u001D",
    "\x1e" => "\\u001E",
    "\x1f" => "\\u001F"
  }.freeze #: Hash[String, String]

  RE_ESCAPE_JS = Regexp.new(ESCAPE_JS_MAP.keys.map { |k| Regexp.escape(k) }.join("|"))

  #: (String) -> String
  def self.escape(s)
    s.gsub(RE_ESCAPE) { |m| ESCAPE_MAP[m] }
  end

  #: (String) -> String
  def self.unescape(s)
    s.gsub(RE_UNESCAPE) { |m| UNESCAPE_MAP[m] }
  end

  def self.escape_js(s)
    s.gsub(RE_ESCAPE_JS) { |m| ESCAPE_JS_MAP[m] }
  end
end
