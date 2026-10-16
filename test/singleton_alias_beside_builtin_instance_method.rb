# A singleton alias (`class << self; alias_method :stamp, :now`) names a class
# method. Beside an instance method of the same name in a reopened builtin it
# was also taken for the instance call's name, so `Time.at(0).stamp` was
# refused ("undefined method 'now' for an instance of Time"), and a bare
# `mk` in a String or Array method was renamed to `new`. A module that does
# `extend self` gave its class side the instance def over the singleton alias,
# or over the module's own class method (`def self.x`, `def Mod.x`, a def in
# `class << self` or `class << Mod`, in any body of the module). And the
# readers of an instance method took a singleton alias of the same name for
# the reader: `attr_reader :a` beside `class << self; alias_method :a, :b`.
# The main object's own `class << self; alias d c` stayed beside a top-level
# `alias` (last lines).
class Time
  class << self
    alias_method :stamp, :now
  end
  def stamp = :inst_stamp
  def twice = [stamp, self.stamp]
end
p Time.at(0).stamp
p Time.at(0).twice

class Time
  class << self
    alias stamp2 now
  end
  def stamp2 = :inst_stamp2
end
p Time.at(0).stamp2

class Time
  def stamp3 = :inst_stamp3
  singleton_class.alias_method :stamp3, :now
end
p Time.at(0).stamp3

class Time
  def self.mine = 7
  class << self
    alias_method :stamp4, :mine
  end
  def stamp4 = :inst_stamp4
end
p Time.at(0).stamp4, Time.stamp4

class Time
  def self.mine5 = 8
  singleton_class.alias_method :stamp5, :mine5
  def stamp5 = :inst_stamp5
end
p Time.at(0).stamp5, Time.stamp5

class String
  class << self
    alias_method :mk, :new
  end
  def mk = :inst_mk
  def twice = [mk, self.mk]
end
p "x".mk, "x".twice

class Array
  class << self
    alias_method :mk, :new
  end
  def mk = :inst_mk
  def twice = [mk, self.mk]
end
p [1].mk, [1].twice

class Hash
  class << self
    alias_method :mk, :new
  end
  def mk = :inst_mk
end
p({a: 1}.mk)

class User
  def self.mk = :cls_mk
  class << self
    alias_method :stamp, :mk
  end
  def stamp = :inst_stamp
  def twice = [stamp, self.stamp]
end
p User.new.twice, User.stamp

module Before
  extend self
  def mk = :mk
  def stamp = :inst_stamp
  class << self
    alias_method :stamp, :mk
  end
end

module After
  extend self
  def mk = :mk
  class << self
    alias stamp mk
  end
  def stamp = :inst_stamp
end

module OwnBefore
  extend self
  def self.x = :own_before
  def x = :inst
  def y = :inst_y
  class << self
    def z = :own_z
  end
  def z = :inst_z
end

module OwnAfter
  extend self
  def x = :inst
  def self.x = :own_after
  def z = :inst_z
  class << self
    def z = :own_z
  end
end

class Includer
  include Before
  include After
end
p Before.stamp, After.stamp, Includer.new.stamp, Includer.new.mk
p OwnBefore.x, OwnBefore.y, OwnBefore.z, OwnAfter.x, OwnAfter.z
class Includer2
  include OwnBefore
  include OwnAfter
end
p Includer2.new.x, Includer2.new.y, Includer2.new.z

module Earlier
  def self.x = :own_earlier
end
module Earlier
  extend self
  def x = :inst
end
module DefMod
  extend self
  def DefMod.x = :own_defmod
  def x = :inst
end
module SingMod
  extend self
  class << SingMod
    def x = :own_singmod
  end
  def x = :inst
end
p Earlier.x, DefMod.x, SingMod.x

class Reader
  attr_reader :a, :b
  def initialize = (@a = :inst_a; @b = :inst_b)
  class << self
    def c = :cls_c
    alias_method :a, :c
    attr_accessor :b
  end
end
Reader.b = :cls_b
p Reader.new.a, Reader.a, Reader.new.b, Reader.b
class SubReader < Reader; end
p [Reader.new, SubReader.new].map(&:a)

def top_a = 1
alias top_b top_a
class << self
  def top_c = 3
  alias top_d top_c
end
p top_d, top_b
