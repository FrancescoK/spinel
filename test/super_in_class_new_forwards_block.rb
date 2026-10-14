class Base
  def self.new(*a) = super
end
class Kid < Base
  def initialize(&b) = @b = b
  def blk = @b
end
p Kid.new { 7 }.blk.call

class StmtBase
  def self.new(*a)
    super
  end
end
class StmtKid < StmtBase
  def initialize(&b) = @b = b
  def blk = @b
end
p StmtKid.new { 8 }.blk.call

class EmptyBase
  def self.new(*a)
    super()
  end
end
class EmptyKid < EmptyBase
  def initialize(&b) = @b = b
  def blk = @b
end
p EmptyKid.new { 9 }.blk.call

class NamedBase
  def self.new(x) = super
end
class NamedKid < NamedBase
  def initialize(x, &b)
    @x = x
    @b = b
  end
  def go = @b.call(@x)
end
p NamedKid.new(4) { |v| v + 1 }.go

module Tracking
  def new(*a)
    super
  end
end
class Tracked
  extend Tracking
  def initialize(&b) = @b = b
  def blk = @b
end
p Tracked.new { 13 }.blk.call
p Kid.new.blk
