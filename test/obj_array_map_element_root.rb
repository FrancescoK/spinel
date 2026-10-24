# A map over an object array binds each element in a local of the block. When
# the block empties the array, that local holds the element alone, and the
# element stays alive while the block allocates.

class Mob
  attr_accessor :hp
  def initialize(hp) = (@hp = hp)
end

class Pack
  def initialize = (@pack = [Mob.new(1), Mob.new(2)])

  def churn
    hps = @pack.map do |m|
      @pack.clear
      i = 0
      while i < 300_000
        Mob.new(i + 10)
        i += 1
      end
      m.hp
    end
    p hps
    nil
  end
end

Pack.new.churn
