# A call to a method that subclasses override dispatches on the receiver's
# class, through a switch over the classes. The switch was built only for a
# return it can carry, and one no arm types (each override ends in a throw,
# an exit, a call to a method of no class) is none: such a call was
# emitted as a direct call to the base class's method, which skipped the
# override, and when only the subclasses define the method there is no base
# method to call and the compiler crashed. Those methods' functions are void,
# and the call dispatches as a void one does.

class Shape
  def run = area
end

class Square < Shape
  def area
    puts "square"
    throw :done
  end
end

class Circle < Shape
  def area
    puts "circle"
    throw :done
  end
end

catch(:done) { Circle.new.run }
catch(:done) { Square.new.run }

class Base
  def go = stop
  def stop
    puts "base"
    throw :done
  end
end

class Child < Base
  def stop
    puts "child"
    throw :done
  end
end

catch(:done) { Child.new.go }
catch(:done) { Base.new.go }
