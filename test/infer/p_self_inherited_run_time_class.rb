# `p self` in a method a class inherits prints the object by its own class,
# with its own instance variables, not by the class the method is defined in:
# P has no object of its own, only C and D do, so the default inspect is asked
# with the object's class id and not P's. The output carries addresses, so
# `make infer-test` runs the program and compares what it prints, less the
# address and the line that interpolates self (which names P, another matter),
# with the .expected beside it.
class P
  def initialize
    @p = 1
  end

  def show
    p self
    puts "#{self}"
  end
end

class C < P
  def initialize
    super
    @c = 2
  end
end

class D < P
  def initialize
    super
    @d = 3
  end
end

C.new.show
D.new.show
