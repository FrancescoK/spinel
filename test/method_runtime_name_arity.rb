class Vehicle
  def put_on = :on
  def note(x) = x
  def shift(a, b = 1) = a + b
end

class Other
  def put_on(gear) = gear
end

def arity_of(object, sym)
  object.method(sym).arity
end

def ev(object, method, *args)
  args = [] if object.respond_to?(method, true) && object.method(method).arity.zero?
  object.send(method, *args)
end

def call_one(object, sym, v)
  object.method(sym).call(v)
end

p arity_of(Vehicle.new, :put_on)
p arity_of(Vehicle.new, :note)
p arity_of(Vehicle.new, :shift)
p arity_of(Other.new, :put_on)
p [Vehicle.new, Other.new].map { |o| o.method(:put_on).arity }
p ev(Vehicle.new, :put_on, 1)
p ev(Vehicle.new, :note, 7)
p ev(Other.new, :put_on, 2)
p call_one(Vehicle.new, :shift, 4)
p call_one(Other.new, :put_on, 5)
