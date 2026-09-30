# A subclass shares the class variable its superclass declares: reading it,
# assigning it and updating it in a subclass reach the one slot, in instance
# methods, class methods and the subclass body, however deep the chain.
class Counter
  @@count = 0
  @@names = []
  @@label = "base"

  def self.count = @@count
  def self.names = @@names
  def initialize(name)
    @@count += 1
    @@names << name
  end
  def count = @@count
end

class Sub < Counter
  def bump = @@count += 10
  def total = @@count
  def note(s) = @@names << s
  def label = @@label
  def self.relabel(s)
    @@label = s
  end
  def self.seen = @@names.size
end

class Deep < Sub
  def deep_count = @@count
  def deep_set(v)
    @@count = v
  end
end

Counter.new("a")
Sub.new("b")
Deep.new("c")
p Counter.count
p Sub.count
p Sub.new("d").total
p Deep.new("e").deep_count

s = Sub.new("f")
p s.bump
p Counter.count
p s.count
s.note("g")
p Counter.names
p Sub.seen

Deep.new("h").deep_set(100)
p Counter.count
p Sub.relabel("sub")
p Deep.new("i").label
p Counter.new("j").count

# A read at the top of a subclass body, and a write from its body.
class Base
  @@shared = 1
end
class Kid < Base
  p @@shared
  @@shared = 7
  def self.shared = @@shared
end
class Grandkid < Kid
  def shared = @@shared
end
p Kid.shared
p Grandkid.new.shared

# ||= and &&= in a subclass, and a slot that widens through a subclass write.
class Cache
  @@memo = nil
  @@flag = true
  def self.memo = @@memo
  def self.flag = @@flag
end
class Warm < Cache
  def self.fill
    @@memo ||= "filled"
    @@flag &&= false
  end
  def self.widen = @@memo = 42
end
Warm.fill
p Cache.memo
p Cache.flag
Warm.widen
p Cache.memo

# Sibling subclasses of a class that does not declare the name keep their own.
class Root; end
class Left < Root
  @@x = "left"
  def self.x = @@x
end
class Right < Root
  @@x = "right"
  def self.x = @@x
end
p Left.x
p Right.x

# A subclass method defined before the superclass declares the variable.
class Early; end
class Late < Early
  def self.v = @@v
  def self.v=(x)
    @@v = x
  end
end
class Early
  @@v = 1
  def self.v = @@v
end
p Late.v
Late.v = 2
p Early.v

# defined?, class_variable_get and class_variable_set through a subclass.
class Reflect
  @@r = 3
end
class ReflectSub < Reflect
  def self.d = defined?(@@r)
end
p ReflectSub.d
p ReflectSub.class_variable_get(:@@r)
ReflectSub.class_variable_set(:@@r, 4)
p Reflect.class_variable_get(:@@r)
p ReflectSub.class_variable_defined?(:@@r)
p ReflectSub.class_variables

# Containers, an object, a widened type and a multiple assignment shared with
# a subclass; the parent may be an exception or a Struct class.
class Reg
  @@items = {}
  @@last = nil
  def self.register(k, v)
    @@items[k] = v
    @@last = v
  end
  def self.items = @@items
end
class Plugin < Reg
  def self.add(k)
    @@items[k] = k.to_s * 2
    @@last = k
  end
  def self.last = @@last
end
Reg.register(:a, "x")
Plugin.add(:b)
p Reg.items
p Plugin.last

class MyErr < StandardError
  @@n = 0
end
class OtherErr < MyErr
  def self.bump = @@n += 1
end
p OtherErr.bump
p OtherErr.bump

class Pt < Struct.new(:a)
  @@made = 0
  def initialize(*)
    super
    @@made += 1
  end
  def self.made = @@made
end
class Pt3 < Pt
  def made3 = @@made
end
Pt.new(1)
Pt3.new(2)
p Pt.made
p Pt3.new(3).made3

class Node
  attr_reader :v
  def initialize(v)
    @v = v
  end
end
class Holder
  @@head = Node.new(1)
  def self.head = @@head
end
class SubHolder < Holder
  def swap = @@head = Node.new(@@head.v + 1)
end
GC.start
sh = SubHolder.new
sh.swap
sh.swap
GC.start
junk = []
5.times { |i| junk << Node.new(900 + i) }
p Holder.head.v
p junk.map(&:v)

class W1
  @@v = 1
  def self.v = @@v
end
class W2 < W1
  def self.set(x)
    @@v = x
  end
end
W2.set("str")
p W1.v

class T1
  @@a, @@b = 1, 2
  def self.ab = [@@a, @@b]
end
class T2 < T1
  def self.m
    @@a, @@b = 5, 6
  end
end
T2.m
p T1.ab

# A subclass rebinding a Hash or an Array the superclass holds.
class Store
  @@h = {}
  @@a = []
  def self.h = @@h
  def self.a = @@a
  def self.put(k, v)
    @@h[k] = v
  end
end
class Swap < Store
  def self.set(other)
    @@h = other
    @@a = other.keys
  end
end
Store.put(:a, 1)
p Store.h
p Store.a
Swap.set({"x" => 2})
p Store.h
p Store.a
Store.put("y", 3)
p Store.h

# A superclass that declares the variable after its subclass has written it,
# in a method or in a reopened body, and one declared by class_variable_set.
class LateBase; end
class LateSub < LateBase
  def self.name_it
    @@x = "sub"
  end
  def self.sx = @@x
end
class LateBase
  def self.init
    @@x = 1
  end
  def self.bx = @@x
end
LateBase.init
p LateBase.bx
LateSub.name_it
p LateSub.sx, LateBase.bx
LateBase.init
p LateSub.sx

class SetBase; end
class SetSub < SetBase
  def self.g = @@x
  def self.s(v)
    @@x = v
  end
end
SetBase.class_variable_set(:@@x, 10)
p SetSub.g
SetSub.s(11)
p SetBase.class_variable_get(:@@x)
SetSub.s("str")
p SetBase.class_variable_get(:@@x), SetSub.g

class ReopenTop; end
class ReopenMid < ReopenTop
  def self.set_ints
    @@a = [1, 2]
  end
  def self.push_a(v)
    @@a << v
  end
  def self.a = @@a
end
class ReopenTop
  @@a = []
end
ReopenMid.set_ints
ReopenMid.push_a("str")
ReopenMid.push_a(3.5)
p ReopenMid.a

# the variables a subclass lists keep the order they were declared in
class OrderBase; end
class OrderSub < OrderBase
  def self.init
    @@a = 1
    @@b = 2
    @@c = 3
    @@d = 4
  end
end
class OrderBase
  @@a = 0
end
OrderSub.init
p OrderSub.class_variables

# Heap values a superclass holds, changed from a subclass, with the collector
# running between the steps and allocation after the last one.
class HeapBase
  @@s = +"start"
  @@a = [1, 2, 3]
  @@h = { "k" => [1] }
  def self.s = @@s
  def self.a = @@a
  def self.h = @@h
end
class HeapSub < HeapBase
  def self.grow
    @@s << "-more"
    @@a << 4
    @@h["j"] = [2, 3]
    @@h["k"] << 9
  end
  def self.swap
    @@s = "swapped-#{@@a.size}"
    @@a = @@a.map { |x| x * 10 }
    @@h = { "n" => @@h.keys }
  end
end
GC.start
HeapSub.grow
GC.start
p HeapBase.s, HeapBase.a, HeapBase.h
HeapSub.swap
GC.start
strs = []
arrs = []
hashes = []
20.times do |i|
  strs << "junk#{i}"
  arrs << [i, i]
  hashes << { i => i }
end
p HeapBase.s, HeapBase.a, HeapBase.h
p [strs.size, arrs.size, hashes.size]
