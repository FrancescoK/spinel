# A constant path is a multiple-assignment target like a bare constant:
# `Mod::P`, a top-level `::X` and `self::Z` in a class body, before and
# after a splat, from a literal, a method's array and a splat.
module Mod; end
Mod::P, Mod::Q = 1, 2
p Mod::P, Mod::Q

::X, ::Y = "x", nil
p X, Y

class Conf
  self::Z, self::W = 3.5, :w
  p self::Z, Conf::W
end

module Mod
  A, *R, B = 1, 2, 3, 4
end
p Mod::A, Mod::R, Mod::B

def pair = [10, 20]
Mod::C, Mod::D = pair
p Mod::C, Mod::D

src = [5, 6, 7]
Mod::E, *Mod::F = *src
p Mod::E, Mod::F
