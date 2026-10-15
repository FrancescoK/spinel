# spinel: share
# spinel: gc-minor
# An object whose instance variable holds an Array of shared Strings is
# rendered, compared, copied and frozen as any object is, the Array shown by
# what it holds.
class Plain
  def initialize = @l = []
  def add(s) = @l << s
  def bang = @l.each { |x| x << "!" }
end
class Named < Plain
end
def norm(x) = x.gsub(/0x\h+/, "X")
s = +"s"
q = Plain.new
q.add(s)
q.add(+"t")
q.bang
n = Named.new
n.add(s)
n.add(+"u")
puts norm(q.inspect), norm("#{q}"), norm(q.to_s)
puts norm({ k: q }.inspect), norm([q].inspect), norm(q.then { |z| z.inspect })
puts norm(n.inspect), norm(n.to_s)
p q.instance_of?(Plain), q.is_a?(Object), n.is_a?(Plain)
c = q.dup
d = q.clone
c.add(+"c")
puts norm(q.inspect), norm(c.inspect), norm(d.inspect)
r = Plain.new
r.add(s)
r.add(+"t")
p q == q, q == r, q.eql?(q), q.equal?(r), q.hash == q.hash
q.freeze
p q.frozen?, c.frozen?
s << "?"
puts norm(q.inspect)
