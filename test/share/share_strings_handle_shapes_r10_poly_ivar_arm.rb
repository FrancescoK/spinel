# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def initialize = @own = +"own"; def pick(t) = @own; attr_reader :own; end
pb = PB.new
s = +"abc"
[PA.new, pb].each { |px| px.pick(s) << "!" }
p s, pb.own
