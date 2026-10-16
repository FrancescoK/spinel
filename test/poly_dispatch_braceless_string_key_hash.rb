# A braceless Hash argument with String keys, passed to a method on a
# receiver of no single known class, reaches a Hash parameter.

class Box
  def initialize(h) = @h = h
  def merge(h) = Box.new(@h.merge(h))
  def to_h = @h
end
class Base
  def self.find_class(name) = Object.const_get(name.to_s.capitalize)
  def self.merge(h) = Box.new({}).merge(h)
end
class Foo < Base; end
class Bar < Base
  def id = 1
  def foo_merge = Base.find_class(:foo).merge("bar_id" => id)
end
p Bar.new.foo_merge.to_h

class Foo2; def take(h) = h; def opts(**o) = o; def self.cm(h) = h; end
class Bar2; def take(h) = h; def opts(**o) = o; def self.cm(h) = h; end
def pick(n) = n == 1 ? Foo2.new : Bar2.new
def pick_cls(n) = n == 1 ? Foo2 : Bar2
p pick(1).take("k" => 1)
p pick(2).take("k" => 1, "j" => 2)
p pick(1).take({"k" => 1})
p pick(1).take(k: 1)
p pick(1).opts("k" => 1)
p pick(1).opts(k: 1)
p pick_cls(1).cm("k" => 1)
p pick_cls(2).cm(k: 1)
