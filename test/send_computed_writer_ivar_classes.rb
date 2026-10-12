class Shop
  def tow = :towed
end

class Truck
  def tow = :hauled
end

class Vehicle
  attr_accessor :shop, :label

  def initialize(attributes)
    attributes.each { |attr, value| send("#{attr}=", value) }
  end

  def tow = shop.tow
end

p Vehicle.new(shop: Shop.new, label: "a").tow
p Vehicle.new(shop: Truck.new, label: "b").tow
