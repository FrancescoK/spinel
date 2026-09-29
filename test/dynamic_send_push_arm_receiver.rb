class Vehicle
  def park(*args) = [:park, args]
end

class Path
  def push(item) = item
end

def keep(&block) = block
def event_name = "park"

helper = keep { |object, *args| object.send(event_name, *args) }
p helper.call(Vehicle.new)
p helper.call(Vehicle.new, 1, 2)
p Path.new.push(3)
