# A Method asked only what it is (its arity, name or source line) calls
# nothing, so the methods it can name stay out of the program: a body
# Spinel would refuse is never compiled.
module Kernel
  def build_case(sup) = Class.new(sup) { }   # never called
end

def each_twice
  yield 1
  yield 2
end

class Case
  def test_one(a, b = 2) = a + b
  def test_two = :two
  def name = ARGV[0] || "test_one"
end

c = [Case.new, 1].first   # a value of either class
p c.method(c.name).arity
p c.method(c.name).name
p c.method(:test_one).source_location.last
p c.method(:test_two).arity
p method(:each_twice).arity
p c.test_two
