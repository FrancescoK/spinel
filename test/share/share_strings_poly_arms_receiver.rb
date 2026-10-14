# A boxed receiver's call whose arms each answer a String (one hands on its
# argument, the other a copy), as the receiver of an in-place change and as
# the value an instance_variable_set stores: the change reaches the String
# the arm handed on, and the ivar holds the handle. (A chain of changes over
# it is refused: refuse/poly_arms_chain_receiver.rb.)
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
class O; attr_accessor :v; end
c = ARGV.size == 0
s = +"abc"
px = c ? PA.new : PB.new
px.pick(s) << "1"
p s
px.pick(s).upcase!
p s
px.pick(s).concat("2")
p s
o = O.new
o.instance_variable_set(:@v, px.pick(s))
s << "4"
p o.v, o.v.equal?(s)
