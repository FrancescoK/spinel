# read-only parameters (borrowed) while the callee and caller allocate
def peek(s) = s.bytesize + s.getbyte(0)
def peek2(s, t) = s.bytesize * 1000 + t.bytesize
@buf = +"abc"
x = @buf
tot = 0
200.times do |i|
  @buf << ("z" * (i % 7))
  tot += peek(@buf)
  tot += peek2(@buf, x)
  y = "t#{i}" * 4
  tot += peek(y)
end
p tot, @buf.size, x.equal?(@buf)
