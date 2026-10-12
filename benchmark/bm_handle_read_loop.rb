# Reads of a shared String handle in a hot loop: its length, a byte and a
# prefix test, each on the handle's live buffer without a copy.
def grow(s) = s << "xyz"
s = +"abc"
grow(s)
t = 0
20_000_000.times do |i|
  t += s.bytesize + s.getbyte(i % 6) + (s.start_with?("ab") ? 1 : 0)
end
p t
