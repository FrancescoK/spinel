# A String grown with << and read back out of a Hash or an Array converts
# as the String it is: to_i, to_i(16), to_f and Integer() (#7263).
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
w = a[0]
p [w.to_i, w.to_f, Integer(w), w.to_i(8)]
