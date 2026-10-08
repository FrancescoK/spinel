# A block nested in a lambda's or a proc's body binds its parameters and
# locals afresh on every run, and every call of the lambda gets its own.
# Such a block is inlined into the lambda's C function, but a name it
# declared that an inner block captured was taken from the frame around the
# lambda: the parameter of a block kept by a `&b` callee named a C slot the
# function never declared (the C build failed), an Array.new index read a
# cell nothing wrote (every kept block answered 0), and a recursive call of
# the lambda rebound a local its caller still read.
# spinel: gc-minor
def keep(&b) = b

f1 = -> { (0...3).map { |i| keep { i } } }
p f1.call.map(&:call)
f2 = -> { [0, 1, 2].map { |i| keep { i * 2 } } }
p f2.call.map(&:call)
f3 = -> { r = []; 3.times { |i| r << keep { i + 10 } }; r }
p f3.call.map(&:call)
f4 = -> { Array.new(3) { |i| keep { i } } }
p f4.call.map(&:call)
f5 = proc { %w[a b].each_with_index.map { |s, i| keep { s * (i + 1) } } }
p f5.call.map(&:call)
f6 = lambda do
  {a: 1, b: 2}.map { |k, v| keep { [k, v] } }
end
p f6.call.map(&:call)

# nested iterators, a lambda in a lambda, a parameter the block reassigns
f7 = -> { (0...2).map { |i| (0...2).map { |j| keep { i * 10 + j } } }.flatten }
p f7.call.map(&:call)
f8 = -> { g8 = -> { (0...3).map { |i| keep { -i } } }; g8.call }
p f8.call.map(&:call)
f9 = -> { (0...3).map { |i| i += 1; keep { i } } }
p f9.call.map(&:call)

# the lambda's own parameter beside the block's, over two calls
f10 = ->(n) { Array.new(n) { |i| keep { i + n } } }
p f10.(3).map(&:call), f10.(2).map(&:call)

# two nested blocks, and the body of a block a `&b` callee keeps
at13 = []
f13 = -> { [1, 2].each { |a| [10, 20].each { |c| at13 << keep { a + c } } } }
f13.call
p at13.map(&:call)
o14 = keep { (0...3).map { |i| keep { i * 3 } } }
p o14.call.map(&:call)

# a local of the block, kept across a recursive call of the lambda
f11 = ->(n) { r = nil; [1].each { |_| y = n; k = keep { y }; r = f11.(n - 1) if n > 0; r = [y, k.call, r] }; r }
p f11.(2)

# a block parameter shadowing a local of the enclosing scope
i = 100
f12 = -> { r = (0...2).map { |i| keep { i } }; r << keep { i }; r }
p f12.call.map(&:call)
