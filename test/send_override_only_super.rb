# A program's send, __send__ or public_send whose whole body is `super`
# answers what Object's does (ruby/spec super_spec: a module's
# `def __send__(name, *args, &block) = super`, included into a class).
module Forwarding
  def __send__(name, *args, &block)
    super
  end
end

class Greeter
  include Forwarding
  def hello(name) = "hello #{name}"
  def bye = "bye"
end

class Plain
  def send(...) = super
  def public_send(name, *args)
    super
  end
  def size = 3
end

g = Greeter.new
p g.__send__(:bye)
p g.__send__(:hello, "ann")
%w[hello bye].each do |m|
  args = m == "hello" ? ["bob"] : []
  p g.__send__(m.to_sym, *args)
end
pl = Plain.new
p pl.send(:size), pl.public_send(:size)
