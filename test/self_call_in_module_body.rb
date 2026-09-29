# `self.m(...)` as a statement of a class or module body calls the class
# object's own method -- activesupport's IsolatedExecutionState sets
# `self.isolation_level = :thread` in its body after defining the writer in
# `class << self`. With `self` the class object there, the call reaches the
# singleton method, as the bare `m` form and `Mod.m` do.

module Conf
  class << self
    attr_reader :level
    def level=(v)
      @level = v.to_s
    end
    def reset = @level = "none"
  end
  self.level = :thread
  p self.level
  p level
  self.reset
  p self.level
  self.level = :fiber
end
p Conf.level

class Store
  def self.limit = @limit ||= 0
  def self.limit=(n)
    @limit = n
  end
  self.limit = 5
  p self.limit + 1
end
p Store.limit
