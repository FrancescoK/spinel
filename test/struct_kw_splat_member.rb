# A keyword_init Struct built with a literal keyword at one site and a `**h`
# at another. The splat's members were typed only by the literal site, so
# the boxed value pulled out of the hash was passed into a String member
# and the C did not build.
Result = Struct.new(:count, :status, keyword_init: true)

def summary = { status: "ok" }

p Result.new(count: 0, status: "empty")
p Result.new(count: 2, **summary)
# a nil through the splat
p Result.new(count: 3, **{ status: nil })
# an Integer member supplied by the splat
p Result.new(**{ count: 4, status: "four" })
# a key the splat does not carry is nil
p Result.new(count: 5, **{})

# Data, the same two shapes
D = Data.define(:x, :y)
p D.new(x: 1, y: "s")
p D.new(x: 2, **{ y: nil })
