# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
class PC; def pick(t) = t.then { |q| q }; end
s = +"abc"
[PA.new, PB.new, PC.new].each { |px| px.pick(s) << "!" }
p s
