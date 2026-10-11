# spinel: share
# A String bang answers nil when it changes nothing, and a String mutator called on
# that nil is NoMethodError naming the mutator. It was FrozenError (the mutability
# check reads a nil receiver as frozen), or an IndexError for setbyte.
def try(label)
  yield
rescue NoMethodError, FrozenError, IndexError => e
  puts "#{label}: #{e.class}: #{e.message}"
end
# the bang, the mutator, value and statement position

s = String.new("abcd")
try('strip!.append_as_bytes') { p(s.strip!.append_as_bytes("z")) }
try('strip!.append_as_bytes stmt') { s.strip!.append_as_bytes("z") }
p s
s = String.new("abcd")
try('strip!.concat') { p(s.strip!.concat("z")) }
try('strip!.concat stmt') { s.strip!.concat("z") }
p s
s = String.new("abcd")
try('strip!.concat') { p(s.strip!.concat("z", "y")) }
try('strip!.concat stmt') { s.strip!.concat("z", "y") }
p s
s = String.new("abcd")
try('strip!.<<') { p(s.strip!.<< "z") }
try('strip!.<< stmt') { s.strip!.<< "z" }
p s
s = String.new("abcd")
try('strip!.prepend') { p(s.strip!.prepend("z")) }
try('strip!.prepend stmt') { s.strip!.prepend("z") }
p s
s = String.new("abcd")
try('strip!.insert') { p(s.strip!.insert(0, "z")) }
try('strip!.insert stmt') { s.strip!.insert(0, "z") }
p s
s = String.new("abcd")
try('strip!.replace') { p(s.strip!.replace("q")) }
try('strip!.replace stmt') { s.strip!.replace("q") }
p s
s = String.new("abcd")
try('strip!.bytesplice') { p(s.strip!.bytesplice(0, 1, "q")) }
try('strip!.bytesplice stmt') { s.strip!.bytesplice(0, 1, "q") }
p s
s = String.new("abcd")
try('strip!.bytesplice') { p(s.strip!.bytesplice(0..0, "q")) }
try('strip!.bytesplice stmt') { s.strip!.bytesplice(0..0, "q") }
p s
s = String.new("abcd")
try('strip!.setbyte') { p(s.strip!.setbyte(0, 65)) }
try('strip!.setbyte stmt') { s.strip!.setbyte(0, 65) }
p s
s = String.new("abcd")
try('strip!.clear') { p(s.strip!.clear) }
try('strip!.clear stmt') { s.strip!.clear }
p s
s = String.new("abcd")
try('chomp!.append_as_bytes') { p(s.chomp!.append_as_bytes("z")) }
try('chomp!.append_as_bytes stmt') { s.chomp!.append_as_bytes("z") }
p s
s = String.new("abcd")
try('chomp!.concat') { p(s.chomp!.concat("z")) }
try('chomp!.concat stmt') { s.chomp!.concat("z") }
p s
s = String.new("abcd")
try('chomp!.concat') { p(s.chomp!.concat("z", "y")) }
try('chomp!.concat stmt') { s.chomp!.concat("z", "y") }
p s
s = String.new("abcd")
try('chomp!.<<') { p(s.chomp!.<< "z") }
try('chomp!.<< stmt') { s.chomp!.<< "z" }
p s
s = String.new("abcd")
try('chomp!.prepend') { p(s.chomp!.prepend("z")) }
try('chomp!.prepend stmt') { s.chomp!.prepend("z") }
p s
s = String.new("abcd")
try('chomp!.insert') { p(s.chomp!.insert(0, "z")) }
try('chomp!.insert stmt') { s.chomp!.insert(0, "z") }
p s
s = String.new("abcd")
try('chomp!.replace') { p(s.chomp!.replace("q")) }
try('chomp!.replace stmt') { s.chomp!.replace("q") }
p s
s = String.new("abcd")
try('chomp!.bytesplice') { p(s.chomp!.bytesplice(0, 1, "q")) }
try('chomp!.bytesplice stmt') { s.chomp!.bytesplice(0, 1, "q") }
p s
s = String.new("abcd")
try('chomp!.bytesplice') { p(s.chomp!.bytesplice(0..0, "q")) }
try('chomp!.bytesplice stmt') { s.chomp!.bytesplice(0..0, "q") }
p s
s = String.new("abcd")
try('chomp!.setbyte') { p(s.chomp!.setbyte(0, 65)) }
try('chomp!.setbyte stmt') { s.chomp!.setbyte(0, 65) }
p s
s = String.new("abcd")
try('chomp!.clear') { p(s.chomp!.clear) }
try('chomp!.clear stmt') { s.chomp!.clear }
p s
s = String.new("abcd")
try('squeeze!.append_as_bytes') { p(s.squeeze!.append_as_bytes("z")) }
try('squeeze!.append_as_bytes stmt') { s.squeeze!.append_as_bytes("z") }
p s
s = String.new("abcd")
try('squeeze!.concat') { p(s.squeeze!.concat("z")) }
try('squeeze!.concat stmt') { s.squeeze!.concat("z") }
p s
s = String.new("abcd")
try('squeeze!.concat') { p(s.squeeze!.concat("z", "y")) }
try('squeeze!.concat stmt') { s.squeeze!.concat("z", "y") }
p s
s = String.new("abcd")
try('squeeze!.<<') { p(s.squeeze!.<< "z") }
try('squeeze!.<< stmt') { s.squeeze!.<< "z" }
p s
s = String.new("abcd")
try('squeeze!.prepend') { p(s.squeeze!.prepend("z")) }
try('squeeze!.prepend stmt') { s.squeeze!.prepend("z") }
p s
s = String.new("abcd")
try('squeeze!.insert') { p(s.squeeze!.insert(0, "z")) }
try('squeeze!.insert stmt') { s.squeeze!.insert(0, "z") }
p s
s = String.new("abcd")
try('squeeze!.replace') { p(s.squeeze!.replace("q")) }
try('squeeze!.replace stmt') { s.squeeze!.replace("q") }
p s
s = String.new("abcd")
try('squeeze!.bytesplice') { p(s.squeeze!.bytesplice(0, 1, "q")) }
try('squeeze!.bytesplice stmt') { s.squeeze!.bytesplice(0, 1, "q") }
p s
s = String.new("abcd")
try('squeeze!.bytesplice') { p(s.squeeze!.bytesplice(0..0, "q")) }
try('squeeze!.bytesplice stmt') { s.squeeze!.bytesplice(0..0, "q") }
p s
s = String.new("abcd")
try('squeeze!.setbyte') { p(s.squeeze!.setbyte(0, 65)) }
try('squeeze!.setbyte stmt') { s.squeeze!.setbyte(0, 65) }
p s
s = String.new("abcd")
try('squeeze!.clear') { p(s.squeeze!.clear) }
try('squeeze!.clear stmt') { s.squeeze!.clear }
p s
s = String.new("abcd")
try('delete!.append_as_bytes') { p(s.delete!("zz").append_as_bytes("z")) }
try('delete!.append_as_bytes stmt') { s.delete!("zz").append_as_bytes("z") }
p s
s = String.new("abcd")
try('delete!.concat') { p(s.delete!("zz").concat("z")) }
try('delete!.concat stmt') { s.delete!("zz").concat("z") }
p s
s = String.new("abcd")
try('delete!.concat') { p(s.delete!("zz").concat("z", "y")) }
try('delete!.concat stmt') { s.delete!("zz").concat("z", "y") }
p s
s = String.new("abcd")
try('delete!.<<') { p(s.delete!("zz").<< "z") }
try('delete!.<< stmt') { s.delete!("zz").<< "z" }
p s
s = String.new("abcd")
try('delete!.prepend') { p(s.delete!("zz").prepend("z")) }
try('delete!.prepend stmt') { s.delete!("zz").prepend("z") }
p s
s = String.new("abcd")
try('delete!.insert') { p(s.delete!("zz").insert(0, "z")) }
try('delete!.insert stmt') { s.delete!("zz").insert(0, "z") }
p s
s = String.new("abcd")
try('delete!.replace') { p(s.delete!("zz").replace("q")) }
try('delete!.replace stmt') { s.delete!("zz").replace("q") }
p s
s = String.new("abcd")
try('delete!.bytesplice') { p(s.delete!("zz").bytesplice(0, 1, "q")) }
try('delete!.bytesplice stmt') { s.delete!("zz").bytesplice(0, 1, "q") }
p s
s = String.new("abcd")
try('delete!.bytesplice') { p(s.delete!("zz").bytesplice(0..0, "q")) }
try('delete!.bytesplice stmt') { s.delete!("zz").bytesplice(0..0, "q") }
p s
s = String.new("abcd")
try('delete!.setbyte') { p(s.delete!("zz").setbyte(0, 65)) }
try('delete!.setbyte stmt') { s.delete!("zz").setbyte(0, 65) }
p s
s = String.new("abcd")
try('delete!.clear') { p(s.delete!("zz").clear) }
try('delete!.clear stmt') { s.delete!("zz").clear }
p s
s = String.new("abcd")
try('sub!.append_as_bytes') { p(s.sub!("zz", "y").append_as_bytes("z")) }
try('sub!.append_as_bytes stmt') { s.sub!("zz", "y").append_as_bytes("z") }
p s
s = String.new("abcd")
try('sub!.concat') { p(s.sub!("zz", "y").concat("z")) }
try('sub!.concat stmt') { s.sub!("zz", "y").concat("z") }
p s
s = String.new("abcd")
try('sub!.concat') { p(s.sub!("zz", "y").concat("z", "y")) }
try('sub!.concat stmt') { s.sub!("zz", "y").concat("z", "y") }
p s
s = String.new("abcd")
try('sub!.<<') { p(s.sub!("zz", "y").<< "z") }
try('sub!.<< stmt') { s.sub!("zz", "y").<< "z" }
p s
s = String.new("abcd")
try('sub!.prepend') { p(s.sub!("zz", "y").prepend("z")) }
try('sub!.prepend stmt') { s.sub!("zz", "y").prepend("z") }
p s
s = String.new("abcd")
try('sub!.insert') { p(s.sub!("zz", "y").insert(0, "z")) }
try('sub!.insert stmt') { s.sub!("zz", "y").insert(0, "z") }
p s
s = String.new("abcd")
try('sub!.replace') { p(s.sub!("zz", "y").replace("q")) }
try('sub!.replace stmt') { s.sub!("zz", "y").replace("q") }
p s
s = String.new("abcd")
try('sub!.bytesplice') { p(s.sub!("zz", "y").bytesplice(0, 1, "q")) }
try('sub!.bytesplice stmt') { s.sub!("zz", "y").bytesplice(0, 1, "q") }
p s
s = String.new("abcd")
try('sub!.bytesplice') { p(s.sub!("zz", "y").bytesplice(0..0, "q")) }
try('sub!.bytesplice stmt') { s.sub!("zz", "y").bytesplice(0..0, "q") }
p s
s = String.new("abcd")
try('sub!.setbyte') { p(s.sub!("zz", "y").setbyte(0, 65)) }
try('sub!.setbyte stmt') { s.sub!("zz", "y").setbyte(0, 65) }
p s
s = String.new("abcd")
try('sub!.clear') { p(s.sub!("zz", "y").clear) }
try('sub!.clear stmt') { s.sub!("zz", "y").clear }
p s
s = String.new("abcd")
try('gsub!.append_as_bytes') { p(s.gsub!("zz", "y").append_as_bytes("z")) }
try('gsub!.append_as_bytes stmt') { s.gsub!("zz", "y").append_as_bytes("z") }
p s
s = String.new("abcd")
try('gsub!.concat') { p(s.gsub!("zz", "y").concat("z")) }
try('gsub!.concat stmt') { s.gsub!("zz", "y").concat("z") }
p s
s = String.new("abcd")
try('gsub!.concat') { p(s.gsub!("zz", "y").concat("z", "y")) }
try('gsub!.concat stmt') { s.gsub!("zz", "y").concat("z", "y") }
p s
s = String.new("abcd")
try('gsub!.<<') { p(s.gsub!("zz", "y").<< "z") }
try('gsub!.<< stmt') { s.gsub!("zz", "y").<< "z" }
p s
s = String.new("abcd")
try('gsub!.prepend') { p(s.gsub!("zz", "y").prepend("z")) }
try('gsub!.prepend stmt') { s.gsub!("zz", "y").prepend("z") }
p s
s = String.new("abcd")
try('gsub!.insert') { p(s.gsub!("zz", "y").insert(0, "z")) }
try('gsub!.insert stmt') { s.gsub!("zz", "y").insert(0, "z") }
p s
s = String.new("abcd")
try('gsub!.replace') { p(s.gsub!("zz", "y").replace("q")) }
try('gsub!.replace stmt') { s.gsub!("zz", "y").replace("q") }
p s
s = String.new("abcd")
try('gsub!.bytesplice') { p(s.gsub!("zz", "y").bytesplice(0, 1, "q")) }
try('gsub!.bytesplice stmt') { s.gsub!("zz", "y").bytesplice(0, 1, "q") }
p s
s = String.new("abcd")
try('gsub!.bytesplice') { p(s.gsub!("zz", "y").bytesplice(0..0, "q")) }
try('gsub!.bytesplice stmt') { s.gsub!("zz", "y").bytesplice(0..0, "q") }
p s
s = String.new("abcd")
try('gsub!.setbyte') { p(s.gsub!("zz", "y").setbyte(0, 65)) }
try('gsub!.setbyte stmt') { s.gsub!("zz", "y").setbyte(0, 65) }
p s
s = String.new("abcd")
try('gsub!.clear') { p(s.gsub!("zz", "y").clear) }
try('gsub!.clear stmt') { s.gsub!("zz", "y").clear }
p s
# a bang that changed the String answers it, and the mutator reaches the variable
s = String.new("  ab ")
s.strip!.concat("x")
p s
s = String.new("xxab")
p s.delete_prefix!("xx").prepend("1"), s
s = String.new("ab\n")
p s.chomp!.insert(0, "<"), s
# a bang that always answers the String, and a read that meets the nil
s = String.new("abcd")
p s.reverse!.concat("z"), s
p s.upcase!.upcase, s
t = String.new("abcd")
p t.strip!.nil?, t.strip!.to_s, t.strip!.inspect, t.strip!&.concat("z")
