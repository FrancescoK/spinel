class Coll
  def <<(x) = self
end

class Base
  def add(x) = items << x
  def total = items.sum
end

class Sub < Base
  attr_reader :items
  def initialize = @items = []
end

class Hidden < Base
  def initialize = @items = [10]
  private
  attr_reader :items
end

module Filler
  def fill(x) = entries << x
end

class Box
  include Filler
  attr_reader :entries
  def initialize = @entries = []
end

class Holder
  include Filler
end

class Crate < Holder
  attr_reader :entries
  def initialize = @entries = []
end

class Named
  def label = name.upcase
end

class ByReader < Named
  attr_reader :name
  def initialize = @name = "reader"
end

class ByDef < Named
  def name = "def"
end

s = Sub.new; s.add(1); s.add(2)
h = Hidden.new; h.add(5)
b = Box.new; b.fill(:a)
c = Crate.new; c.fill(:b); c.fill(:c)
p [s.items, s.total, h.total, b.entries, c.entries, Coll.new << 1 ? :ok : :no]
p [ByReader.new.label, ByDef.new.label]
