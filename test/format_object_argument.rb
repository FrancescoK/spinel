# String#% with one object of the program's own classes as its argument: the
# object is one argument, %s is its to_s and %p its inspect, as in CRuby.

class Path
  def initialize(s) = @s = s
  def to_s = @s
  def inspect = "#<Path #{@s}>"
end

class Base
  def to_s = "base"
end

class Child < Base
end

class Quiet
end

def pick(n) = n > 0 ? Path.new("p#{n}") : nil

x = Path.new("index.js")
puts "Reading %s" % x
puts "[%-12s]" % x
puts "[%12s]" % x
puts "as %p" % x
puts "child %s" % Child.new
puts ("%s" % Quiet.new).start_with?("#<Quiet")
puts "maybe %s" % pick(1)
puts "maybe [%s]" % pick(0)
puts "built %s" % Path.new("tmp" + "/out")
begin
  puts "%d" % x
rescue TypeError => e
  puts e.class
end
begin
  puts "%s %s" % x
rescue ArgumentError => e
  puts e.message
end
