# A poly `count(arg)` whose receiver is an Array or a String answers an
# Integer, while a user `count` elsewhere answers an Integer or nil: the
# builtin's answer is held as that nilable Integer (#8716).
class Limits
  def initialize(qty)
    @count = qty.nil? ? nil : Integer(qty)
  end

  def count
    @count
  end
end

def total(store)
  store.count("a")
end

puts total(rand < 2 ? ["a", "b", "a"] : "banana")
puts total(rand < 2 ? "banana" : ["a"])
puts Limits.new("4").count
p Limits.new(nil).count
