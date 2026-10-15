# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t + ""; end
class O; attr_reader :v; end
s = +"abc"
os = []
100.times do |i|
  px = i.even? ? PA.new : PB.new
  o = O.new
  o.instance_variable_set(:@v, px.pick(s))
  x = "z" * 200
  os << o
end
s << "!"
p os[0].v, os[1].v, os.count { |o| o.v.equal?(s) }
