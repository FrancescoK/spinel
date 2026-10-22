# A walk over an array of one class can be the last statement of a method.
# The array stays unboxed when no caller reads the method's value, and a
# caller that reads it gets the array.

class Mob
  attr_accessor :hp
  def initialize(hp) = (@hp = hp)
end

# Each call discards the value: a statement followed by another, the last
# statement of a `times` block and the last statement of a `while` body.
class Herd
  def initialize = (@herd = [Mob.new(10), Mob.new(20)])

  def hurt_all
    @herd.each { |m| m.hp -= 1 }
  end

  def total = @herd.sum { |m| m.hp }
end

h = Herd.new
h.hurt_all
p h.total
2.times { h.hurt_all }
i = 0
while i < 2
  i += 1
  h.hurt_all
end
p h.total

# The walk ends a method that ends another method, whose callers discard
# the value.
class Flock
  def initialize = (@flock = [Mob.new(5)])
  def tick = feed

  def feed
    @flock.each { |m| m.hp += 1 }
  end

  def hp = @flock[0].hp
end

f = Flock.new
f.tick
f.tick
p f.hp

# A guard return comes first, and the block has more than one statement.
class Pack
  def initialize = (@pack = [Mob.new(3), Mob.new(0)])

  def blast(dmg)
    return if dmg <= 0

    @pack.each do |m|
      next unless m.hp > 0

      m.hp -= dmg
    end
  end

  def first_hp = @pack[0].hp
end

k = Pack.new
k.blast(0)
k.blast(1)
p k.first_hp

# Each of these callers reads the value, which is the array.
class Swarm
  def initialize = (@swarm = [Mob.new(7), Mob.new(8)])

  def poke
    @swarm.each { |m| m.hp += 1 }
  end

  def poke_twice = poke
  def run = yield
end

s = Swarm.new
s.poke
p s.poke.size
x = s.poke
p x[1].hp
p [0].map { s.poke }[0].size
p s.run { s.poke }.size
p s.poke_twice[0].hp
p s.public_send(:poke).size
p(s.poke ? 1 : 2)
case s.poke
when Array then p :arr
end
p s.poke == s.poke

# Pattern matching calls deconstruct with no call node, and `b.items ||= v`
# calls the getter. Both read the value.
class Pile
  def initialize = (@pile = [Mob.new(1), Mob.new(2)])
  def deconstruct = @pile.each { |m| m.hp += 1 }
end

case Pile.new
in [a, b] then p [a.hp, b.hp]
end

class Bag
  def initialize = (@bag = [Mob.new(1), Mob.new(2)])
  def items = @bag.each { |m| m.hp += 0 }

  def items=(v)
    @bag = v
  end

  def count = @bag.size
end

b = Bag.new
b.items ||= [Mob.new(4)]
p b.count
