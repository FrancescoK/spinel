# An empty class-variable hash written only through a getter takes its
# key and value types from those writes.

class SymInt
  @@h = {}
  def self.h = @@h
end
SymInt.h[:a] = 1
p SymInt.h

class IntArr
  @@h = {}
  def self.h = @@h
end
IntArr.h[1] = [1.5]
p IntArr.h

class Inst
  @@h = {}
  def h = @@h
end
Inst.new.h[:a] = 1
p Inst.new.h

module Mod
  @@h = {}
  def self.h = @@h
end
Mod.h[:a] = 1
p Mod.h

class Adder
  @@h = {}
  def self.h
    @@h
  end
  def self.add(k, v) = h[k] = v
end
Adder.add(:a, 1)
Adder.add(:b, 2)
p Adder.h[:a] + Adder.h[:b]

class OrWrite
  @@h = {}
  def self.h = @@h
end
OrWrite.h[:a] ||= 5
OrWrite.h.store(:b, 6)
p OrWrite.h

class DirectOrWrite
  @@h = {}
  def self.f = (@@h[:a] ||= 5)
  def self.h = @@h
end
DirectOrWrite.f
p DirectOrWrite.h
