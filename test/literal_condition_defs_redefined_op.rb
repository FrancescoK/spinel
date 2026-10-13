# A comparison whose operator the program redefines is not fixed by its
# literals: here Integer#== says true, so the def runs. (Asked by calling
# it: a lone def under a run-time condition is not asked about by name.)
class Integer
  def ==(other) = true
end

class Shape
  if 1 == 2
    def area = 1
  end
end

p Shape.new.area
