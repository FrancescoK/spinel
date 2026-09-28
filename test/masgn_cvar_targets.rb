# A class variable a multiple assignment writes is declared by that
# assignment, in a method or a class body, before or after a splat, from a
# literal, a method's array, a scalar and a splat.
class Reg
  def self.pair = [10, 20]

  def self.run
    @@a, @@b = 1, "b"
    p @@a, @@b
    @@c, *@@d = [1, 2, 3]
    p @@c, @@d
    @@e, @@f = pair
    p @@e, @@f
    @@g, @@h = 7
    p @@g, @@h
    @@k, *@@l, @@m = 8
    p @@k, @@l, @@m
    src = [4, 5]
    @@i, *@@j = *src
    p @@i, @@j
  end
end
Reg.run

class Body
  @@x, *@@y, @@z = 1, 2, 3, 4
  p @@x, @@y, @@z
end
