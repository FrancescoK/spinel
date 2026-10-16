# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
s = +"abc"
h = { "k" => "v" }
h["a"], h["b"] = id(s), s.then { |q| q }
s << "!"
p h, h["a"].equal?(s), h["b"].equal?(s)
