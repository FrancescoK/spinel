# A module that does `extend self` gets a `def self.x` clone of each instance
# def, which took the place of the module's own class-level accessor of the
# name (`class << self; attr_reader :x; end` beside `def x`): `M.x`, a call of
# `x` in a class method and an instance method called on the module all ran
# the instance def. The accessor wins, as the singleton class
# holds it itself; an includer keeps the instance def.
module Reader
  extend self
  @x = 5
  class << self
    attr_reader :x
  end
  def x = :inst
  def self.go = x
  def self.go2 = self.x
end
p Reader.x, Reader.go, Reader.go2
p Reader.send(:x)
class UsesReader
  include Reader
end
p UsesReader.new.x

module Accessor
  extend self
  class << self
    attr_accessor :y
  end
  def y = 10
  def twice = y * 2
end
Accessor.y = 7
p Accessor.y, Accessor.twice

module Writer
  extend self
  class << self
    attr_writer :z
    def peek = @z
  end
  def z=(v)
    @inst = v
  end
  def inst = @inst
end
Writer.z = :own
p Writer.peek, Writer.inst

module Before
  extend self
  def w = :inst
  class << self
    attr_reader :w
  end
  @w = :own_before
end
p Before.w
