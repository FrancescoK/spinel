# `C[k] = v` answers v when the class-level `[]=` is the program's.

class Reg
  @h = {}
  def self.[]=(k, v)
    @h[k] = v * 2
    :ret
  end
  def self.[](k) = @h[k]
  def self.fill
    r = (self[:s] = 9)
    p r
    [1].each { |i| p(self[i] = 11) }
  end
end

class SubReg < Reg
  @h = {}
end

module Ns
  class Box
    def self.[]=(*a)
      :box
    end
  end
end

module Store
  def []=(k, v)
    (@s ||= {})[k] = v
    :ext
  end
end

class Ext
  extend Store
end

module Conf
  @r = {}
  class << self
    def []=(k, v)
      @r[k] = v
      nil
    end
    def [](k) = @r[k]
    def set_all
      q = (self[:t] = "t")
      p q
    end
  end
end

class Picky
  def self.[]=(k, v)
    raise ArgumentError, "zero" if k == 0
    :picky
  end
end

def get = (Conf[:e] = :e)

p(Reg[1] = 2)
y = (Reg[3] = 4)
p y
p Reg[3]
k = Reg
p(k[5] = 6)
p(Ns::Box[1, 2] = 3)
p(SubReg[:e] = 5)
Reg.fill
z = (Reg[side = 7] = 8)
p [z, side]
puts(Reg[:q] = 10)
Reg[1] += 5
p Reg[1]
p(Ext[1] = 2)
p(Conf[:a] = "x")
Conf[:b] = "y"
p Conf[:b]
w = Conf[:c] = 3
p w
p [Conf[:d] = 4, 5]
p get
Conf.set_all
begin
  p(Picky[0] = 1)
rescue ArgumentError => e
  p e.message
end
p(Picky[1] = nil)
p(Picky[2] = true)
h = {}
p(h[:z] = 1)
