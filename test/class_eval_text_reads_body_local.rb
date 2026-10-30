# The text of a class_eval in a class or module body runs in the body's
# frame: it reads and writes the body's locals, as CRuby's eval does, in a
# block it makes too, and a local the body assigns only later is one it
# knows (nil until then).
class K
  y = 5
  class_eval "Z = y + 1"
  class_eval "y = 9; W = y"
  p y
  class_eval "y += 1; y *= 3; a, y = 5, y + 1; V = [a, y]"
  p y
  class_eval "define_method(:twice) { y * 2 }"
  class_eval "LATER = defined?(zz).inspect"
  zz = 1
end
p K::Z, K::W, K::V, K.new.twice, K::LATER

module M
  w = 4
  module_eval "def mw = 2\nMW = w"
end
class C
  include M
end
p C.new.mw, M::MW
