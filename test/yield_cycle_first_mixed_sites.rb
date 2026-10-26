# cycle.first(n) and cycle.take(n) on a yield whose block answers different
# kinds per site: each site's bounded elements are one poly array, so the
# Array, Hash, String and Float sites print as CRuby does. A typed Array's own
# cycle.first stays an Array.
def w
  p yield.cycle.first(3)
  p yield.cycle.take(4)
  p yield.cycle.first(0)
end
w { [1, 2] }
w { { a: 1 } }
w { ["x", "y"] }
w { [1.5, nil] }
w { [] }
def t = [7, 8].cycle.first(3)
p t
x = [1, 2].cycle.first(2)
p x
