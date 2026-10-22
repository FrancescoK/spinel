# An instance variable write in value position stores an Array literal
# into a slot that holds an unboxed array of one class.

class Mob
  attr_reader :hp
  def initialize(hp) = (@hp = hp)
end

class Herd
  def initialize = (@herd = [Mob.new(10), Mob.new(20)])
  def reset(n) = (@herd = [Mob.new(n), Mob.new(n + 1)])

  def total
    t = 0
    @herd.each { |m| t += m.hp }
    t
  end
end

h = Herd.new
p h.total
h.reset(5)
p h.total
