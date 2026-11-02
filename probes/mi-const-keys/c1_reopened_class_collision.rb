class Calc
  SIZE = 3
  def self.size = SIZE
end
class Small
  SIZE = 4
end
class Calc
  def self.both = [SIZE, Small::SIZE]
end
SIZE = 9
p Calc.size, Calc.both, Small::SIZE, SIZE
