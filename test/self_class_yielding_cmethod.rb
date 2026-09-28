module MacroMethods
  def machine(*, &)
    find(self, *, &)
  end

  def find(owner, name)
    block_given? ? yield(name) : "#{owner}:#{name}"
  end
end

Class.class_eval do
  include MacroMethods
end

module VehicleHelpers
  def parked?
    self.class.machine(:state)
  end
end

class Vehicle
  include VehicleHelpers

  def self.pick(name)
    yield name
  end

  def size = self.class.pick(:state) { |n| n.size * 2 }
  def label = self.class.pick(:state) { |n| "#{n}!" }
end

v = Vehicle.new
p v.parked?
p v.size
p v.label
p Vehicle.machine(:x) { |n| n.to_s * 2 }
