# Built under --int-overflow=wrap by infer-test: an overflowing +, - or *
# wraps, and a comparison of the wrapped value sees it. The arithmetic was
# signed C, whose overflow is undefined, so an optimizing C compiler folded
# `x + 1 < x` to false. ARGV.size keeps the operands unknown to the C
# compiler. (Raise mode, the default build of this directory, rescues.)
n = ARGV.size
x = 9223372036854775807 - n
y = -9223372036854775807 - n
z = 3037000500 + n
begin
  p x + 1 < x
  p x * 2 < x
  p y - 2 > y
  p z * z > 0
rescue RangeError
  p :overflow
end
