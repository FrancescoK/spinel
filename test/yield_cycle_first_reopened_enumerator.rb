# A program that reopens Enumerator#first and #take answers its own first and
# take for cycle.first(n) and cycle.take(n) on a yield, beside an Array block
# and a Hash block, and for a typed Array's cycle as well; the bounded cycle
# does not stand in for either.
class Enumerator
  def first(n) = "reopened-first #{n}"
  def take(n) = "reopened-take #{n}"
end
def w
  p yield.cycle.first(3)
  p yield.cycle.take(3)
end
w { [1, 2] }
w { { a: 1 } }
p [1, 2].cycle.first(3)
p [1, 2].cycle.take(3)
