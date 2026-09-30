# `const_get(name)` with a name known only at run time. Every constant the
# program defines is known at compile time, so the call lowers to a static
# dispatch over those names (the way a runtime `send` does): the arm for the
# name that matches answers the constant, a class or a value, and a name that
# matches none raises the NameError CRuby raises. The activesupport shape is
# `Object.const_get(camel_cased_word)` (Inflector#constantize).
module Carts
  class A
    def initialize(x) = @x = x
    def x = @x
  end
  class B < A; end
  SIZE = 3
  LABEL = "carts"
  def self.build(t, x) = const_get(t).new(x)
  def self.constantize(name) = Object.const_get(name)
end

names = %w[A B]
p Carts.build(names[0].to_sym, 1).x
p Carts.build(names[1], 2).x
k = ARGV.empty? ? "A" : "B"
p Carts.const_get(k)
p Carts.const_get(k).new(9).x
p Carts.const_get(["SIZE", "LABEL"].sample(random: Random.new(0)).then { "SIZE" })
p Carts.const_get("LAB" + "EL")
p Carts.constantize("Carts")::SIZE
p Carts.constantize("Carts").name
sym = :SIZE
p Carts.const_get(sym) + 1

def name_error(&) = yield rescue p($!.message)
name_error { Carts.const_get("Nope".dup) }
name_error { Object.const_get("Nope".dup) }
name_error { Carts.const_get("lower".dup) }
