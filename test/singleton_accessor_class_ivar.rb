class Tuned
  @level = 1
  class << self
    attr_accessor :level
    def current = level
    def bump = (self.level = level + 1)
  end
end

class Counter
  class << self
    attr_accessor :count
  end
  def self.seen = @count
  def self.reset = (@count = 0)
end

p Tuned.current
Tuned.bump
p Tuned.level
p Tuned.current
Counter.count = 4
p Counter.seen
Counter.reset
p Counter.count
