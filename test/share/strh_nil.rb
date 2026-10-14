# spinel: share
# spinel: gc-minor
# Out-of-range reads, a gap, and an empty Array of shared Strings.
s = +"s"
a = [s]
p a[1], a[-2], a.first, a.last
a[3] = s
p a, a.size
puts a.inspect
puts a.join("-")
puts a
e = [s]
e.pop
p e.pop, e.shift, e.first, e.last, e.empty?, e.size
s << "!"
p a
begin
  a[-9] = s
rescue IndexError => e
  puts e.message
end
a[-1] = +"last"
p a
