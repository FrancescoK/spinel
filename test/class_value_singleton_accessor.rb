# A `class << self` accessor called on a class value only the run time knows
# (a parameter, `self.class` in a class with a subclass, a local holding
# `self.class`) reads and writes the slot of the class the value is, and a
# class without the accessor raises NoMethodError, as in CRuby.
class Base
  class << self
    attr_accessor :label
  end
  @label = "base"
end
class Num < Base
end
class Plain
end
module Conf
  class << self
    attr_reader :level
  end
  @level = 3
end
Num.label = 42
def show(k) = k.label
def set(k, v) = (k.label = v)
p show(Base), show(Num)
p set(Num, :sym), Num.label
def try_label(k)
  k.label
rescue NoMethodError => e
  e.message
end
p try_label(Plain), try_label(Base)
m = Conf
p m.level
class Base
  def own_label = self.class.label
  def local_label
    k = self.class
    k.label
  end
end
p Base.new.own_label, Num.new.own_label, Num.new.local_label
