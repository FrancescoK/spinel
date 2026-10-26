# A call on a boxed receiver is typed from the classes its receiver can hold
# (the class facts), as its dispatch arms are: Money#to_i, Money#size and
# Label#area answer nil or a String, but no receiver below ever holds a
# Money or a Label, so `as_int` and `area_of` answer an Integer and `count`
# an Integer or nil, as they would if those methods did not exist.

class Money
  def initialize(cents) = @cents = cents
  def to_i = @cents
  def size = "large"
end

class Square
  def initialize(side) = @side = side
  def area = @side * @side
end

class Label
  def area = "n/a"
end

def pick(i) = [7, "42", 2.5][i]

def as_int(i)
  v = pick(i)
  v.to_i
end

def count(i)
  v = [[1, 2], "xyz"][i]
  v.size
end

def shape(i) = [Square.new(3), nil][i]

def area_of(i)
  s = shape(i)
  s ? s.area : 0
end

total = 0
3.times { |i| total += as_int(i) }
p total
p count(0) + count(1)
p area_of(0) + area_of(1)
p Money.new(5).to_i
p Money.new(nil).to_i
p Money.new(1).size
p Label.new.area
