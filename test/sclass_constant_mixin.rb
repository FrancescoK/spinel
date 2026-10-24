# A prepend or include inside `class << Const` at the top level, Const a
# class the program declares, is that class's singleton mixin, as
# `class << self` in its body is: the prepended module's method answers
# first, an included one answers what the class itself does not define.
module Logged
  def call(x) = super(x) + 1
end
module Named
  def label = "svc:#{name}"
end
class Svc
  def self.call(x) = x * 10
end
class << Svc
  prepend Logged
  include Named
end
p Svc.call(5)
p Svc.label
