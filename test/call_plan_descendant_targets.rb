# The call plan records descendant, accessor, constructor and class targets.
class PlanParent
  def run(n) = leaf(n)
  def explicit_run(n) = self.leaf(n)
end
class PlanChild < PlanParent
  def leaf(n) = n + 1
end
p PlanChild.new.run(4), PlanChild.new.leaf(5), PlanChild.new.explicit_run(6)
class PlanFactory
  def self.make = new
end
class PlanFactory
  def self.new = :made
end
p PlanFactory.make
class PlanFake
  def class = :not_a_class
end
p PlanFake.new.class
class PlanReopened; end
class PlanReopened
  def class = :reopened
end
p PlanReopened.new.class

# module singleton accessor holding one of several class constants
class Fast
  def self.run(x) = x * 2
  def self.label = "fast"
end
class Slow
  def self.run(x) = x + 100
  def self.label = :slow
end
class Slower < Slow
  def self.run(x) = super(x) + 1
end
module Cfg
  class << self
    attr_accessor :impl
  end
end
Cfg.impl = Fast
p Cfg.impl.run(5), Cfg.impl.label
Cfg.impl = Slow
p Cfg.impl.run(5), Cfg.impl.label
Cfg.impl = Slower
p Cfg.impl.run(5), Cfg.impl.label
s = Cfg.impl.label
p s

# A boxed builtin receiver retains its Class result.
p [PlanFake.new, 1][ARGV.size + 1].class
