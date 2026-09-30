# A hash spread into a literal of another variant -- `{**h, "s" => nil}`
# with `h = {"s" => 2}`: the pairs make it a String-keyed poly hash, which a
# String-to-Integer one cannot be merged into -- was refused as a double-splat
# of an unmergeable source. So was a call passing such keywords, to a lambda
# or as a positional hash. The literal is built as the hash of any key and
# value, which merges every variant at run time.

h = {"s" => 2}
p({**h, "s" => nil})
p({"t" => "u", **h})
x = {"a" => [1], **h}
x["b"] = :c
p x
g = {"z" => 1.5}
p({**h, **g})

def pos(a) = a
p pos(**h, "s" => nil)

f = ->() { [] }
p((f.call(**h, "s" => nil) rescue $!.message))
kw = ->(**o) { o }
p kw.call(**h, "t" => [1])
one = ->(a) { a }
p one.call(**h, "t" => 1.5)

# the same variant still merges directly
p({**h, "t" => 3})
p({**{s: 2}, t: "u"})
