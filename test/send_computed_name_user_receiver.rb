# A computed method name (interpolation, `to_sym`, concatenation) sent to a
# user-class receiver dispatches over everything that receiver answers: its
# methods, readers and writers, and the Object methods every instance has.
# A name it does not answer raises NoMethodError, as in CRuby.

class Vehicle
  attr_accessor :speed

  def initialize = (@speed = 0; @state = "parked")
  def ignite(*a, **k) = (@state = "idling"; [:ignite, a, k])
  def park = (@state = "parked"; true)
  def shift_up! = [:bang, @state]
  def state = @state
end

v = Vehicle.new
[:ignite, :park].each { |e| p v.send("#{e}") }
name = "ignite"
p v.send(name.to_sym, 1, x: 2)
p v.send("shift_up" + "!")
p v.send("speed=", 5)
p v.send("sp" + "eed")
p v.send("cla" + "ss")
p v.public_send("pa#{"rk"}")

begin
  v.send("fl" + "y")
rescue NoMethodError
  puts "statement send of an unknown name raised"
end
r = begin
  v.send("fl" + "y")
rescue NoMethodError
  "value send of an unknown name raised"
end
puts r

# a boxed receiver holding instances of two classes
class Boat
  def ignite(*a, **k) = [:boat, a]
  def state = "moored"
end

[Vehicle.new, Boat.new].each do |o|
  p o.send("ig" + "nite", 1)
  p o.send("st#{"ate"}")
end

class Greeter
  def greet = yield(3)
  def name = "g"
  alias nickname name
end
p Greeter.new.send("gre" + "et") { |x| x * 2 }
p Greeter.new.send("nick" + "name")

class Parent
  def choose = send("ch" + "ild")
end
class Child < Parent
  def child = :kid
end
p Child.new.choose
