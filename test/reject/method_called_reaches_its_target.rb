# A Method that is called, not only asked its arity, reaches every method
# its runtime name can be: the Kernel method below is one of them, and its
# body is refused.
module Kernel
  def build_case(sup) = Class.new(sup) { }
end

class Case
  def test_one = :one
  def name = ARGV[0] || "test_one"
end

c = [Case.new, 1].first
m = c.method(c.name)
p m.arity
p m.call
