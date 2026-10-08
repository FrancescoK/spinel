require "uri"

# The encoding argument, as Rack's unescape passes it
s = URI.decode_www_form_component("a+b%20c%C3%A9", Encoding::UTF_8)
p s, s.encoding
b = URI.decode_www_form_component("%C3%A9", Encoding::BINARY)
p b, b.encoding, b.bytesize
p URI.decode_www_form_component("x%20y").encoding
begin
  URI.decode_www_form_component("100%", Encoding::UTF_8)
rescue ArgumentError => e
  puts e.message
end
