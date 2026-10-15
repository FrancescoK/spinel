# Flag-only. Kernel#String of `A.new(...)` builds exactly an A, so only A's
# conversion answers it: B, a subclass whose #to_s would answer the String it
# holds, is never built here (it is only named), and does not make the call
# that String. The A answers a copy, which may be changed.
class A
  def initialize(n) = @n = n
  def to_s = @n.dup
end
class B < A
  def to_s = @n
end
s = String(A.new(+"c"))
s << "!"
p s
p B
