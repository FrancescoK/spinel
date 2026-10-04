# A fold whose block reads an element out of the accumulator, such as
# walking a nested hash by a key path, answers that element. The block's
# tail was taken for the accumulator itself (as `acc << x` is), so the
# accumulator kept the seed hash's type, and the C did not compile.
# activesupport's NumberToRoundedConverter#default_value walks DEFAULTS
# this way.
D = { a: { b: 1, c: "x" }, d: 2 }
def dv(key) = key.split(".").reduce(D) { |h, k| h[k.to_sym] }
p dv("a.b")
p dv("a.c")
p dv("d")
p dv("a")
