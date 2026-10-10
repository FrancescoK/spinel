# spinel: share
# spinel: gc-minor
# A message returned from a method, a block or a safe call is the plain read
# unless the share facts say it is shared: it compares by identity.
class B < StandardError
  def msg2 = self.message
end
n = ARGV.size
m = B.new(+"x#{n}")
def bar(s) = s
def tos(ex) = ex.to_s
def msg(ex) = ex.message
p [1, bar(m.message).equal?(m.message), m.message.equal?(bar(m.message))]
p [2, tos(m).equal?(m.message), m.to_s.equal?(tos(m))]
p [3, m.msg2.equal?(m.message), m.message.equal?(m.msg2)]
y = [m].map { |q| q.message }.first
p [4, y.equal?(m.message)]
p [5, m.message.object_id == bar(m.message).object_id]
z = m.message.itself
p [6, z.equal?(m.message)]
w = nil
w = m.message if m
p [7, w.equal?(m.message)]
w2 = m&.message
p [8, w2.equal?(m.message)]
r = msg(m)
p [9, r.equal?(m.message), r.equal?(msg(m)), msg(m).equal?(m.message), m.message.equal?(msg(m))]
tos(m)
p [10, m.message.itself.equal?(m.message), m.message.object_id == z.object_id]
