# A String grown with << and read back out of a Hash or an Array is a shared
# String handle there: to_i answered 0, and to_f, to_i(16), Integer() raised
# (#7263). It converts as the String it holds.
s = +""
s << "17"
puts s.to_i              # 17 on both: a local is fine

h = { "n" => s }         # same with h["n"] = s, an Array element, a Symbol key
v = h["n"]
p v                      # "17"
puts v.length            # 2
puts v.to_i
puts v.dup.to_i
puts v.to_s.to_i
begin
  puts Integer(v)
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  puts v.to_i(16)
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  puts v.to_f
rescue => e
  puts "#{e.class}: #{e.message}"
end

a = [s]
v2 = a[0]
[v2].each do |v|
  puts Integer(v)
  puts v.to_i(16)
  puts v.dup.to_i
  puts Float(v)
  puts v.to_r rescue p $!
  puts v.to_c rescue p $!
  puts v.hex
  puts v.oct
  puts v.ord
  puts v + "x"
  puts v * 2
  puts v.to_sym.inspect
end
p [Integer(v2), v2.to_i(16), Float(v2), v2.to_f, v2.to_i, v2.to_r, v2.to_c]
