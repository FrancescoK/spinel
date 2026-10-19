# A Class value that is the answer of a rescue clause, in the last statement
# of a method. The caller calls a class method that constructs `new` on the
# class it got; the analysis asks whether a class value is handed on, and
# did not read the rescue clause as a place a value passes on from, so
# Circle was taken for a class that never reaches a receiver it cannot see.
# The class method was not copied for it, and the call raised NoMethodError
# at run time. The clause is read now.
class Shape
  def self.build = new
  def name = "shape"
end
class Circle < Shape; def name = "circle"; end
class Square < Shape; def name = "square"; end

def pick(flag)
  begin
    raise "boom" if flag
    Square
  rescue
    Circle
  end
end

puts Shape.build.name
puts pick(true).build.name
puts pick(false).build.name
