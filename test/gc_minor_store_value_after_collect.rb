# spinel: gc-minor
# A store whose value is a method's last statement (a setter's `self.user =
# find`) on an object still young at the store's start: the value's
# collections promote the holder, so the barrier has to run after the value
# is in the slot, not before it is computed (#9277). The generational
# verifier reports a holder the barrier did not record.
class User
  def initialize(n) = (@n = n; @tags = ["a", "b"])
  def ok? = @n.is_a?(Integer) && @tags.size == 2
end
class Conn
  attr_accessor :user
  def initialize = (@user = nil)
  def connect = self.user = find
  def find
    GC.start
    GC.start
    User.new(rand(1000))
  end
end
keep = []
20.times do
  c = Conn.new
  c.connect
  keep << c
  junk = []
  3000.times { |i| junk << "j#{i}" * 4 }
end
p keep.map { |c| c.user.ok? }.uniq
