# A Class value that a call answers (`x.class`, `superclass`) and a poly slot
# holds is boxed with its class's index as cls_id, as a constant naming a
# class is. A dispatch on that slot keyed its switch by cls_id alone unless
# the program named a class as a value, so the Class value entered the arm of
# the class it stands for and read an instance out of its class index: a
# segfault, where CRuby raises NoMethodError for a Class that has no such
# method. Here the only Class values come from calls.
class Filler; end

class Point
  attr_reader :x
  def initialize(x = 1) = @x = x
  def inspect = "#<Point x=#{@x}>"
  def label(prefix) = "#{prefix}#{@x}"
  def each_part
    yield @x
    yield @x + 1
  end
end

class Point3 < Point
end

def try
  r = yield
  puts "=> #{r.inspect}"
end

# a block's value: an instance, then the Class values of a call
try { 7 }
try { Point.new }
try { Point.new.class }
try { Point3.new.class.superclass }

# the same values in an Array, read through every kind of arm
vals = [Point.new(5), Point3.new(6).class, Point.new(7).class, Point3.new(8)]
vals.each do |v|
  puts v.inspect
  begin
    puts v.x
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
  begin
    puts v.label("L")
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
  begin
    v.each_part { |n| puts n }
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
end

# held in an ivar and a Hash, and handed back by a method
class Holder
  def initialize(obj)
    @held = obj.class
    @inst = obj
  end
  attr_reader :held, :inst
end
h = Holder.new(Point.new(9))
slots = [h.held, h.inst, { k: h.inst.class }[:k]]
slots.each do |v|
  puts v.inspect
  begin
    puts v.x
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
end
