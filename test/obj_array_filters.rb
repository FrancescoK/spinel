# An array of one class stays unboxed through reject!, select!, select and
# reject. A filter with a bang can be the last statement of a method whose
# value no caller reads, and a caller that reads its value gets the array
# or nil.

class Mob
  attr_accessor :hp, :age
  def initialize(hp, age) = (@hp = hp; @age = age)
  def gone? = @hp <= 0
  def alive? = @hp > 0
  def baby? = @age < 2
end

# A block with more than one statement, then nil.
class Herd
  def initialize = (@herd = [])
  def add(m) = (@herd << m; nil)

  def remove_gone
    @herd.reject! do |m|
      gone = m.gone?
      puts "gone #{m.age}" if gone
      gone
    end
    nil
  end

  def hps = @herd.map(&:hp)
end

h = Herd.new
h.add(Mob.new(1, 5)); h.add(Mob.new(0, 6)); h.add(Mob.new(2, 1))
h.remove_gone
h.remove_gone
p h.hps

# A symbol block at the end of a method, called from a `times` block and
# from a `while` body.
class Volley
  def initialize = (@arrows = [Mob.new(2, 0), Mob.new(1, 0)])

  def update
    @arrows.each { |a| a.hp -= 1 }
    @arrows.select!(&:alive?)
  end

  def size = @arrows.size
end

v = Volley.new
v.update
p v.size
2.times { v.update }
i = 0
while i < 2
  v.update
  i += 1
end
p v.size

class Clutch
  def initialize = (@eggs = [Mob.new(0, 0), Mob.new(3, 0)])
  def hatch = @eggs.reject!(&:gone?)
  def first_hp = @eggs[0].hp
end

c = Clutch.new
c.hatch
p c.first_hp

# A filter without a bang makes a new array of the same class.
class Pen
  def initialize = (@pen = [Mob.new(5, 1), Mob.new(6, 9), Mob.new(7, 0)])

  def report
    babies = @pen.select(&:baby?)
    adults = @pen.reject { |m| m.baby? }
    p babies.size, babies[0].hp, adults.map(&:hp)
    babies.each { |m| m.age += 1 }
    nil
  end

  def ages = @pen.map(&:age)
end

pen = Pen.new
pen.report
p pen.ages

# Each of these callers reads the value of a filter with a bang: the array
# when the filter removes an element, and nil when it removes none.
class Swarm
  def initialize = (@swarm = [Mob.new(1, 0), Mob.new(0, 0), Mob.new(2, 0)])
  def cull = @swarm.reject!(&:gone?)
  def keep = @swarm.select!(&:alive?)
end

s = Swarm.new
r = s.cull
p r.size
p s.cull
p s.keep
p(s.cull ? 1 : 2)

# A block that empties its own array. A filter with a bang that keeps an
# element past the new end fills the gap with nil, and the element that a
# block holds after the array lets it go stays alive while the block
# allocates.
class Cut
  def initialize = (@cut = [Mob.new(1, 0), Mob.new(0, 0), Mob.new(2, 0), Mob.new(0, 0), Mob.new(5, 0)])

  def prune
    @cut.reject! do |m|
      @cut.clear if m.hp == 2
      m.hp == 0
    end
    nil
  end

  def hps = @cut.map { |m| m ? m.hp : -1 }

  def churn
    @cut = [Mob.new(1, 0), Mob.new(2, 0)]
    kept = @cut.select do |m|
      @cut.clear
      i = 0
      while i < 300_000
        Mob.new(i + 10, 0)
        i += 1
      end
      m.hp == 1
    end
    p kept.size
    nil
  end

  def sweep
    @cut = [Mob.new(1, 0), Mob.new(0, 0)]
    @cut.reject! do |m|
      @cut.clear
      i = 0
      while i < 300_000
        Mob.new(i + 10, 0)
        i += 1
      end
      p m.hp
      m.hp == 1
    end
    p hps
    nil
  end
end

cut = Cut.new
cut.prune
p cut.hps
cut.churn
cut.sweep
