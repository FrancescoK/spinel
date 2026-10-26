# A program that reopens Enumerator#first answers its own first for
# cycle.first(n) on a yield, beside an Array block and a Hash block, and for a
# typed Array's cycle.first as well; the bounded cycle does not stand in for it.
class Enumerator
  def first(n) = "reopened-first #{n}"
end
def w
  p yield.cycle.first(3)
end
w { [1, 2] }
w { { a: 1 } }
p [1, 2].cycle.first(3)
