# A filter with a bang whose block clears its own array leaves the array
# empty, as CRuby does, also when the filter kept elements before the clear.
# The kept elements are not brought back, and the block can allocate after
# the clear without the array holding freed objects.

class Mob
  attr_accessor :hp
  def initialize(hp) = (@hp = hp)
end

# An array of one class, which narrows.
class Pack
  def initialize = (@pack = [Mob.new(1), Mob.new(2), Mob.new(3)])

  def cut
    @pack.reject! do |m|
      if m.hp == 2
        @pack.clear
        i = 0
        while i < 300_000
          Mob.new(i + 10)
          i += 1
        end
        true
      else
        false
      end
    end
    nil
  end

  def keep_and_clear
    @pack = [Mob.new(4), Mob.new(5)]
    @pack.select! do |m|
      @pack.clear
      m.hp == 4
    end
    nil
  end

  def size = @pack.size
end

k = Pack.new
k.cut
p k.size
k.keep_and_clear
p k.size

# A boxed array of mixed elements.
mixed = [1, "a", 2, "b"]
mixed.select! do |x|
  mixed.clear if x == "a"
  x != "a"
end
p mixed
