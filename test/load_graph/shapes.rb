# Only definitions: loading it runs nothing.
class Shape
  def initialize(side)
    @side = side
  end

  def area
    @side * @side
  end
end

def square_of(n)
  Shape.new(n).area
end
