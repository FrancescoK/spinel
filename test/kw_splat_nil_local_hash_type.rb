# A `**` of a local that only ever holds nil spreads nothing, and inference
# read it that way while it ran, so a hash built with it took its pairs'
# variant: `"s" => 2, **h` a String to Integer hash. Once inference is done
# such a local is boxed, and the hash is built with the boxed spread merged
# in at run time, into a hash of any key -- which the parameter it bound, or
# the local it was assigned, no longer matched. A positional parameter took
# it (a post beside a rest, a required, a lone one): the C did not compile,
# and splatted before it, the program crashed. So did a hash literal.

def post(*r, a) = [r, a]
def req(x, a) = [x, a]
def lone(a) = a
def keys(a) = a.keys

h = nil
p post(1, "s" => 2, **h)
p post(*[1], "s" => 2, **h)
p post(*[], "t" => "u", **h)
p req(1, "s" => 2, **h)
p lone("s" => 2, **h)
p keys("s" => 2, **h)

# the operand a parameter that only ever holds nil
def via(o) = post(1, "s" => 2, **o)
p via(nil)

# a hash literal, and one written to after
x = {**h, "a" => 1}
p x
y = {"a" => 1, **h}
y["b"] = 2
p y

# a Symbol key or a keyword parameter was already right
p post(1, s: 2, **h)
def kw(k: 1, **o) = [k, o]
p kw(k: 2, "z" => 3, **h)
