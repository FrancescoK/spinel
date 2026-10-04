# IO::Buffer each/each_byte/values/get_values/set_values, and the locked
# block: data access stays allowed inside it, while free/resize/transfer
# and a second locked refuse -- and the lock is released by a raise out of
# the block (Ruby 4.0.7; 4.0.4 left it locked, and every later call in the
# outer block refused).
def try(label)
  r = yield
  puts "#{label}: => #{red(r.inspect)}"
rescue => e
  puts "#{label}: #{e.class}: #{e.message}"
end
def red(s)
  s.gsub(/0x[0-9a-f]+/, "0xX")
end
puts "== iteration =="
b = IO::Buffer.new(8); b.set_string("ABCDEFGH")
try("each") { acc = []; r = b.each(:U8) { |o, v| acc << [o, v] }; [r.equal?(b), acc] }
try("each u16") { acc = []; b.each(:u16) { |o, v| acc << [o, v] }; acc }
try("each off") { acc = []; b.each(:u16, 1) { |o, v| acc << [o, v] }; acc }
try("each cnt") { acc = []; b.each(:u16, 1, 2) { |o, v| acc << [o, v] }; acc }
try("each odd") { acc = []; IO::Buffer.new(5).each(:u16) { |o, v| acc << [o, v] }; acc }
try("each noargs") { acc = []; b.each { |o, v| acc << v }; acc }
try("each_byte") { acc = []; r = b.each_byte { |v| acc << v }; [r.equal?(b), acc] }
try("each_byte args") { acc = []; b.each_byte(2, 3) { |v| acc << v }; acc }
try("values") { b.values(:u16) }
try("values def") { b.values }
try("values args") { b.values(:U8, 6, 2) }
try("values null") { IO::Buffer.new(0).values(:U8) }
try("get_values") { b.get_values([:U8, :u16], 0) }
try("get_values empty") { b.get_values([], 3) }
try("get_values nonarray") { b.get_values(:U8, 0) }
try("set_values") { b.set_values([:U8, :U8], 0, [1, 2]) }
try("set_values mism") { b.set_values([:U8], 0, [1, 2]) }
try("bad each type") { b.each(:zz) { } }
puts "== locked =="
l = IO::Buffer.new(4)
try("locked ret") { l.locked { |arg| [arg.equal?(l), l.locked?] } }
try("after") { l.locked? }
try("nested") { l.locked { l.locked { 1 } } }
try("write in") { l.locked { l.set_value(:U8, 0, 1) } }
try("read in") { l.locked { l.get_value(:U8, 0) } }
try("get_string in") { l.locked { l.get_string } }
try("slice in") { l.locked { l.slice(0, 2) } }
try("dup in") { l.locked { l.dup } }
try("resize in") { l.locked { l.resize(8) } }
try("transfer in") { l.locked { l.transfer } }
try("free in") { l.locked { l.free } }
try("hexdump in") { l.locked { l.hexdump } }
try("clear in") { l.locked { l.clear } }
try("value after") { l.set_value(:U8, 0, 3); l.get_value(:U8, 0) }
