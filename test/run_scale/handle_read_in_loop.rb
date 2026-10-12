# run-scale: 1000 | 16000 | 1.5
# A shared String handle read in a loop (its bytes, its length, a byte)
# allocates nothing per pass: the bytes stay flat when the loop runs 16x.
def grow(s) = s << "x"
s = +"abc"
grow(s)
n = ARGV[0].to_i
t = 0
n.times do |i|
  t += s.bytesize + s.getbyte(i % 3) + (s.start_with?("ab") ? 1 : 0)
end
p t
