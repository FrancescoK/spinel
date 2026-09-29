class Machine
  attr_accessor :state
  def go(a, b) = a
end

class Other
  attr_accessor :state
end

class Weird
  def method(name) = [:mine, name]
end

def ar(object, sym) = object.method(sym).arity

p [Machine.new, Other.new].map { |o| [ar(o, :state=), ar(o, :state)] }
p ar([Machine.new, Other.new].first, :go)
