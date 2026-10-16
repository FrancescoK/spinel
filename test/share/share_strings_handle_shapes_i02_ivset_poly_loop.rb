# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
class O; attr_reader :v; end
s = +"abc"
[PA.new, PB.new, PA.new].each do |px|
  o = O.new
  o.instance_variable_set(:@v, px.pick(s))
  o.v << "."
  p [o.v, o.v.equal?(s)]
end
p s
