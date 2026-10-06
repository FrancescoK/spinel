require "uri"

p URI.decode_www_form("a=1&b=2")
p URI.decode_www_form("a=x+y&b=%E3%81%82&c=")
p URI.decode_www_form("")
p URI.decode_www_form("flag&a=1")
p URI.decode_www_form("a=1&&b")
p URI.decode_www_form("a=1&")
p URI.decode_www_form("&a=1")
p URI.decode_www_form("k=a=b")
p URI.decode_www_form("a=100%&b=%zz&c=%4")
p URI.decode_www_form("a=1;b=2", separator: ";")
p URI.decode_www_form("one&two=2", isindex: true)
p URI.decode_www_form("a=1", Encoding::UTF_8)
begin
  URI.decode_www_form("a=é")
rescue ArgumentError => e
  puts e.message
end
p URI.decode_www_form(URI.encode_www_form([["x y", "a&b=c"], ["k", "é"]]))
p URI.decode_www_form_component("%E3%81%82+x")
p URI.decode_www_form_component("%E3%81%82").encoding
