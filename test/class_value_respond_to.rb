module Registry
  def machines = (@machines ||= [])
end

class Class
  include Registry
end

class Vehicle
  def self.build = new
end

class Robot
  def machines = [:arm]
end

def check(klass) = [klass.respond_to?(:machines), klass.respond_to?(:build), klass.respond_to?(:nope)]

p check(Vehicle)
p check(Robot)
p check(String)

k = [Vehicle, Robot].sample
p k.respond_to?(:machines)

items = [Vehicle, Robot.new, 1]
p items.map { |x| x.respond_to?(:machines) }
p items.map { |x| x.respond_to?(:build) }
