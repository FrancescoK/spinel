# unpack1(fmt, offset: n) on a boxed String (a read that may be nil, a value
# out of a mixed Array): with the keyword the call had no arm and no type,
# and raised NoMethodError or answered nil (#7317).
r, w = IO.pipe
w.write("\x01\x00\x01\x00\x00\x00\x02\x40\x49\x0f\xdb".b)
w.close
s = r.read(11) || raise(IOError)
p s.bytesize
p s.unpack1("C")
p s.unpack1("L>", offset: 3)
p s.unpack1("C", offset: 2)
p s.unpack1("g", offset: 7).round(4)
p s.unpack1("a2", offset: 9).bytes
pos = 1
p s.unpack1("n", offset: pos + 1)

m = ["\x00\x00\x00\x07abc".b, 5][0]
p m.unpack1("N")
p m.unpack1("a3", offset: 4)
p m.unpack1("C", offset: 7)

begin
  s.unpack1("C", offset: 99)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  [5, "x"][0].unpack1("C", offset: 0)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
