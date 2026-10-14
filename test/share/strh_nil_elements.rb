# spinel: share
# spinel: gc-minor
# An element read past the end, a gap and the pop, shift, first and last of
# an empty Array are nil, and answer as nil does: a method of the String
# raises NoMethodError, nil's own answer for itself.
s = +"s"
a = [s, +"t"]
s << "!"
begin
  a[5] << "!"
rescue NoMethodError => e
  puts e.message
end
begin
  x = a[5]
  p x.size
rescue NoMethodError => e
  puts e.message
end
begin
  p a[5].size
rescue NoMethodError => e
  puts e.message
end
begin
  p a[-9].upcase
rescue NoMethodError => e
  puts e.message
end
a[3] = s
begin
  a[2] << "g"
rescue NoMethodError => e
  puts e.message
end
p a, a[2], a[2].nil?, a[2].equal?(nil), a[2] == nil, a[1].nil?
y = a[7]
p y.equal?(nil), y.nil?, y
p a[9]
print a[9], "\n"
puts "#{a[9]}|#{a[2]}"
q = [s]
q.pop
z = q.pop
p z, q.first, q.last, q.shift
begin
  p z.size
rescue NoMethodError => err
  puts err.message
end
begin
  p q.first.size
rescue NoMethodError => err
  puts err.message
end
begin
  q.last << "x"
rescue NoMethodError => err
  puts err.message
end
begin
  q.shift.upcase
rescue NoMethodError => err
  puts err.message
end
q << s
p q, q.pop.equal?(s), q.pop

# a block parameter bound to the nil of a gap
g = [s, +"t"]
g[3] = s
begin
  g.each { |x| x << "." }
rescue NoMethodError => err
  puts err.message
end
begin
  g.each { |x| p x.size }
rescue NoMethodError => err
  puts err.message
end
g.each { |x| p x.nil? }
p g, s

# the identity of an element read or removed is its String's
r = [s, +"u", s]
p r[0].equal?(s), r[1].equal?(s), r.first.equal?(r[2]), r.last.equal?(s)
p r.shift.equal?(s), r.pop.equal?(s), r.pop.equal?(s), r.pop.nil?
