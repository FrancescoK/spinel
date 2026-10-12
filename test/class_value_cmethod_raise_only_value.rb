# A class method whose body only raises, called through a class value
# (`self.class.table_name`) in value position: the call's type stayed poly
# while the C function is void, so the assignment read a void value and the
# C did not build (#8645). The call keeps the method's void, as it does on a
# constant receiver: it runs for its effect (the raise) and reads as nil.
# A module the class extends, a method with a parameter, a class method of
# the class itself, and a subclass whose own class method answers a String
# beside the void one.
module Model
  def table_name
    raise NotImplementedError, "subclasses must declare"
  end
  def with_arg(x = 1)
    raise NotImplementedError, "with_arg #{x}"
  end
end

class Base
  extend Model
  def initialize
    declared = self.class.table_name
    @label = declared
  end
end

class Probe < Base
end

begin
  Probe.new
rescue NotImplementedError => e
  puts "raised: " + e.message
end
begin
  v = Base.with_arg(2)
  p v
rescue NotImplementedError => e
  puts "raised: " + e.message
end

class Plain
  def self.boom
    raise ArgumentError, "boom"
  end
  def go
    r = self.class.boom
    r
  end
end
begin
  Plain.new.go
rescue ArgumentError => e
  puts "raised: " + e.message
end

class Named
  def self.table_name
    raise NotImplementedError, "no table"
  end
  def initialize = @label = self.class.table_name
  def label = @label
end
class Users < Named
  def self.table_name = "users"
end
p Users.new.label
begin
  Named.new
rescue NotImplementedError => e
  puts "raised: " + e.message
end
