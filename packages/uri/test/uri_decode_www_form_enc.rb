require "uri"

# decode_www_form tags its keys and values with the encoding argument
pairs = URI.decode_www_form("k%C3%A9=v%C3%A9&b=x+y", Encoding::BINARY)
p pairs
pairs.each { |k, v| p [k.encoding, v.encoding, v.bytesize] }
enc = [Encoding::UTF_8, 1][0]
p URI.decode_www_form("a=%C3%A9", enc), URI.decode_www_form("a=%C3%A9", enc)[0][1].encoding
p URI.decode_www_form("a=%FF").map { |k, v| [v, v.encoding] }
p URI.decode_www_form("a=%FF", Encoding::BINARY).map { |k, v| [v, v.encoding] }
