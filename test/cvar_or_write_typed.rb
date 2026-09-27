# A class variable written only by `||=`, `&&=` or `op=` is registered and
# typed from those writes, and `||=` / `&&=` test the slot's nil sentinel.

class K
  def self.v = (@@v ||= 5)
  def s = (@@s ||= "a")
  @@f ||= 3.5
  def self.f = @@f
  def self.sym
    @@sym ||= :sym
  end
  def self.bump
    @@n ||= 0
    @@n += 1
  end
  def self.arr = (@@arr ||= [1, 2])
  def self.twice
    @@t ||= 1
    @@t &&= @@t * 2
  end
  def self.str
    @@buf ||= ""
    @@buf += "ab"
  end
  @@w = 1
  def self.widen = (@@w += 0.5)
end

p K.v + 1
p K.v
p K.new.s + "b"
p K.f + 1
p K.sym
p K.sym.to_s + "!"
K.bump
p K.bump * 10
p K.arr.size + 1
p K.arr.map { |x| x * 2 }
p K.twice + 1
p K.twice
K.str
p K.str.size
p K.widen
