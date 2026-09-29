class Vehicle
  attr_accessor :speed
end
class Boat
  attr_accessor :speed
end
class Car
  def gear=(v)
    @gear = v
  end
  def gear = @gear
end
Point = Struct.new(:x, :y)
def vehicle(object, method, *args) = object.send(method, *args)
def point(object, method, *args) = object.send(method, *args)
def car(object, method, *args) = object.send(method, *args)
def any(object, method, *args) = object.send(method, *args)
def rd(object, method) = object.send(method, *[])
v = Vehicle.new
p vehicle(v, :speed=, 7)
p rd(v, :speed)
pt = Point.new(1, 2)
p point(pt, :x=, 5)
p pt
c = Car.new
p car(c, :gear=, 9)
p c.gear
[Vehicle.new, Boat.new].each { |o| p any(o, :speed=, 3) }
[[], [1, 2]].each do |args|
  [-> { vehicle(v, :speed=, *args) }, -> { point(pt, :y=, *args) },
   -> { car(c, :gear=, *args) }, -> { any(Boat.new, :speed=, *args) }].each do |f|
    f.call
  rescue ArgumentError => e
    p e.message
  end
end
p v.speed
