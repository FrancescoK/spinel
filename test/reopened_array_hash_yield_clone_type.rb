# A yielding method added to Array or Hash is called through its proc
# form, a clone that takes the block as a proc and reads the yield as a
# boxed value. The call was typed from the method's own body instead, which
# reads its parameters as the callers' arguments and the yield as a block
# value no call site supplies: `def ys(a) = [a, yield(size)]` was an Array
# of Integer at the call and an Array of boxed values in the clone, and the
# C did not build. The call now answers what the clone returns.
class Array
  def ys(a) = [a, yield(size)]
  def yb(a = 1) = block_given? ? [a, yield(a)] : [a, :none]
end
class Hash
  def hs(a) = [a, yield(size)]
end

lp = proc { |v| "lp#{v}" }
p [1].ys(1) { |v| "x#{v}" }
p [1].ys(2) { |v| v * 2 }
p [1, 2].ys(3, &lp)
a = [1, 2]
p a.ys(4) { |v| { v => v } }
p [1].yb(5)
p([1].yb(6) { |v| [v] })
p({ a: 1 }.hs(7) { |v| "h#{v}" })
h = { b: 2, c: 3 }
p h.hs(8, &lp)
