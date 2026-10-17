# `self.x = v` in a class method that subclasses also run is v as written,
# whichever class's writer the call reaches: a subclass's writer that
# returns something else does not widen the call's value.
class Opt
  attr_accessor :v
  def initialize(v) = @v = v
end

module Wrapper
  module ClassMethods
    def set(o)
      opts = Opt.new(o)
      self.w = opts
    end
  end
end

class Base
  extend Wrapper::ClassMethods
  @w = 1
  def self.w = @w
  def self.w=(val); @w = val; end
end

class Sub < Base; end

class Other < Base
  def self.w=(val); @w = [val]; :ignored; end
end

p Base.w
p Sub.set(2).v
p Base.set(3).v
p Other.set(4).v
p Other.w.map(&:v)
p Base.w.v
