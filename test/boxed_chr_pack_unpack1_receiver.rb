# chr, pack and unpack1 on a boxed receiver without them: CRuby raises
# NoMethodError (with the call's arguments), where chr read a Symbol or a
# Float as its #to_s and answered its first character (nil, ""), pack
# answered "" and unpack1 read the value's #to_s. A String, an Integer
# and an Array answer as before.

def t
  p yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
rescue => e
  puts "#{e.class}: #{e.message}"
end

def fmt(f)
  puts "fmt"
  f
end

k = ARGV.size
[nil, 65, :sy, "sa", 2.5, [65, 66], {a: 1}, 300, [:a]].each do |v|
  n = [v, 0][k]
  t { n.chr }
  t { n.pack(fmt("C*")) }
  t { n.unpack1(fmt("C")) }
end
