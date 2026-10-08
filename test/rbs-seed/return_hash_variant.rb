# A method's C return type comes from its --rbs signature while the expression
# it answers is typed from observed dataflow. Where ivar writes widen a hash
# past the signature's variant the two are separate C structs, and the return
# went back uncoerced (#4095). The assignment side already made this
# conversion; the return side did not.
# spinel: rbs-seed-check
class Jar
  def initialize(inbound = {})
    @inbound = {}
    @out = {}
    inbound.each { |k, v| @inbound[k.to_s] = v }
  end

  def to_h
    @inbound.merge(@out)
  end

  def add(k, v)
    @out[k] = v
    self
  end
end

p Jar.new({ "a" => "b" }).to_h
p Jar.new({ "a" => "b" }).add("c", "d").to_h
p Jar.new.to_h

class SymJar
  def initialize
    @h = {}
    [[:a, 1]].each { |k, v| @h[k] = v }
  end

  def to_h
    @h
  end
end

p SymJar.new.to_h
