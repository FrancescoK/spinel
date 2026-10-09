t = "  aB\xFFc\n  ".b
x = [1, "  aB\xFFc\n  ".b][1]
[["typed", t], ["boxed", x]].each do |k, s|
  r = s.strip
  puts "#{k} strip #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.lstrip
  puts "#{k} lstrip #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.rstrip
  puts "#{k} rstrip #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.chomp
  puts "#{k} chomp #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.chomp("c")
  puts "#{k} chomp_c #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.chop
  puts "#{k} chop #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.squeeze
  puts "#{k} squeeze #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.squeeze("a")
  puts "#{k} squeeze_a #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.delete("a")
  puts "#{k} delete #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.tr("a", "b")
  puts "#{k} tr #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.tr_s("a", "b")
  puts "#{k} tr_s #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.sub("a", "x")
  puts "#{k} sub #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.gsub("a", "x")
  puts "#{k} gsub #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.reverse
  puts "#{k} reverse #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.upcase
  puts "#{k} upcase #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.downcase
  puts "#{k} downcase #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.capitalize
  puts "#{k} capitalize #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.swapcase
  puts "#{k} swapcase #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.center(12)
  puts "#{k} center #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.ljust(12)
  puts "#{k} ljust #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.rjust(12)
  puts "#{k} rjust #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.delete_prefix(" ")
  puts "#{k} delete_prefix #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.delete_suffix("  ")
  puts "#{k} delete_suffix #{r.encoding} #{r.bytes.inspect} #{r.length}"
  r = s.succ
  puts "#{k} succ #{r.encoding} #{r.bytes.inspect} #{r.length}"
end

b = "  aB\xFFc\n  ".b
b.upcase!
puts "upcase! #{b.encoding} #{b.bytes.inspect}"
c = "  aB\xFFc\n  ".b
c.strip!
puts "strip! #{c.encoding} #{c.bytes.inspect}"

u = [1, "xxhixx"][1]
p u.strip("x")
p u.lstrip("x")
p u.rstrip("x")
p u.strip("x", "x-z")
p "ÿ".upcase
p "ÿ".capitalize
