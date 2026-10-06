# spinel: int64 -- -2^63 is an Integer past 2^31; not run on a 32-bit target
# A real -2^63 stored into an Integer slot that can also hold nil. The slot's
# nil is the word INT64_MIN (SP_INT_NIL), so the value read back as nil. The
# store now raises RangeError: the slot cannot hold it. (CRuby holds the
# Integer; this is the one place the typed slot cannot, so the .expected is
# spinel's, not CRuby's.) Every other slot and every plain computation is
# untouched.
m = -(2**62) * 2

# a local that is also assigned nil
x = 5
x = nil if m == 0
begin
  x = m
  p x
rescue RangeError => e
  puts "local: #{e.class}"
end

# an instance variable that is also assigned nil
class Box
  def initialize = @v = nil
  def set(n) = @v = n
  attr_reader :v
end
b = Box.new
begin
  b.set(m)
  p b.v
rescue RangeError => e
  puts "ivar: #{e.class}"
end


# a parameter that is also passed nil
def f(v) = v
f(nil)
begin
  p f(m)
rescue RangeError => e
  puts "param: #{e.class}"
end

