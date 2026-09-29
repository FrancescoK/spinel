# Encoding#ascii_compatible? and Encoding#dummy? on the boxed Encoding a
# String hands out: cgi's pure-Ruby escapeHTML starts with
#   enc = string.encoding
#   unless enc.ascii_compatible? ... end
# and the call raised NoMethodError at run time. Every encoding Spinel
# produces (UTF-8, US-ASCII, ASCII-8BIT) is ASCII-compatible and none is a
# dummy, as in CRuby.

enc = "abc".encoding
p enc.ascii_compatible?, enc.dummy?
p "abc".b.encoding.ascii_compatible?
p Encoding::UTF_8.ascii_compatible?, Encoding::US_ASCII.ascii_compatible?, Encoding::BINARY.dummy?

def escape_html(string)
  enc = string.encoding
  unless enc.ascii_compatible?
    return "non-ascii-compatible"
  end
  string.gsub("<", "&lt;")
end
puts escape_html("<b>")
e2 = [Encoding::UTF_8, 0][0]
p e2.ascii_compatible?
