# The value of a safe-navigation attribute assignment whose receiver can be
# nil, for an attr_accessor: nil when a receiver is nil (the writer and the
# rest of the chain are skipped), else the right-hand side's String itself,
# which changes with it, answers equal? true and is frozen through every
# name; through a receiver that is nil, a boxed one holding nil or the
# object, with the value kept, chained, dropped, changed and frozen, and a
# bang in the chain that answers nil or its receiver.
class K
  attr_accessor :a
  def initialize = (@a = +"init")
end

o = K.new
pair = [o, nil]
none = nil
bn = pair[1]
bo = pair[0]

# a receiver that is nil, and a boxed one that holds nil: the writer and the
# rest of the chain are skipped, and the value is nil
s = +"s"
r = (none&.a = s)
p r
r = (bn&.a = s)
p r
r = (bn&.a = s) || +"d"
r << "1"
p [o.a, s, r]
p (none&.a = s)&.<<("!")&.<<("?"), s
p (bn&.a = s)&.freeze, s.frozen?
(bn&.a = s)&.<<("!")
bn&.a = s
p o.a, s

# a boxed receiver that holds the object: the right-hand side's String
r = (bo&.a = s)
r << "2"
p [o.a, s, r, r.equal?(s), o.a.equal?(s)]
r = (bo&.a = s)&.<<("3")&.<<("4")
p [o.a, s, r.equal?(s)]
bo&.a = s
s << "5"
p o.a
(bo&.a = s)&.<<("6")&.<<("7")
(o.a = s)&.<<("8")&.<<("9")
p s, o.a.equal?(s)

# a bang in the chain that answers nil ends it with nil; one that changes
# the String answers it
t = +"t"
r = (o.a = t)&.sub!("zz", "y")&.<<("!")
p r, t, o.a
r = (bo&.a = t)&.sub!("zz", "y")&.<<("!")
p r, t, o.a
r = (o.a = t)&.sub!("t", "u")&.<<("!")
p r, t, o.a, r.equal?(t)
r = (bo&.a = t)&.upcase!
p r, t, o.a.equal?(t)
(bo&.a = t)&.sub!("U", "v")&.<<("?")
p t, o.a

# the value then frozen, through every name
u = +"u"
r = (bo&.a = u)
r.freeze
p u.frozen?, o.a.frozen?
w = +"w"
r = (bo&.a = w)&.<<("!")
r&.freeze
p w, w.frozen?, o.a.frozen?
