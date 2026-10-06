# Encoding#inspect of the binary encoding is "#<Encoding:BINARY (ASCII-8BIT)>"
# since Ruby 3.4 (its #name and #to_s stay "ASCII-8BIT"); the other encodings
# inspect by name. Typed and boxed.
p "".b.encoding
p Encoding::UTF_8, Encoding::BINARY, Encoding::ASCII_8BIT, Encoding::US_ASCII
puts "".b.encoding, "".b.encoding.name
e = ["".b, 1][0]
p e.encoding
p e.encoding.inspect
p [Encoding::BINARY, Encoding::UTF_8]
puts "#{Encoding::BINARY.inspect} #{Encoding::BINARY}"
