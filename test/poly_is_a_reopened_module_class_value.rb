# A boxed class or module value answers is_a?(Module) (and a class
# is_a?(Class)) where the program reopens Module and some class defines its
# own is_a?: Module was taken as a class of the program's, whose check asks
# for a program object under it, which a class value never is.
# activesupport's lazy load hooks run `base.is_a?(Module) ? base.class_eval
# : base.instance_eval`, and ActionDispatch::Request took instance_eval.
class Module
  def extra = 1
end

class Class
  def extra2 = 2
end

class Thing
  def is_a?(k) = k == Thing
end

class Req; end
module Mod; end

def boxed(x) = x

vals = [boxed(Req), boxed(Mod), boxed(1), boxed("s"), boxed(Thing.new)]
p vals.map { |v| v.is_a?(Module) }
p vals.map { |v| v.is_a?(Class) }
p vals.map { |v| v.kind_of?(Object) }
p vals.last.is_a?(Thing)
# and the class value of a class with its own is_a? is no instance of it:
# the dispatch's switch on cls_id took it into that instance arm
p boxed(Thing).is_a?(Module), boxed(Thing).is_a?(Thing)
