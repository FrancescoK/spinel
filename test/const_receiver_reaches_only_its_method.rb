# `Const.m` names one class, so only the method that call resolves to is
# reached, not every method sharing the name. A same-named method in an
# unrelated module that nothing calls stays out of the program -- here it
# uses `binding`, which spinel cannot compile, so reaching it would refuse
# the whole program. A `super` in the reached method still reaches up.

module Evaluator
  def validate!(code) = eval(code, binding)
  module_function :validate!
end

module Counter
  def validate!(code) = code.size
  module_function :validate!
end

p Counter.validate!("abcd")

class Base
  def self.label = "base"
end

class Child < Base
  def self.label = "child<" + super + ">"
end

p Child.label
p Base.label
