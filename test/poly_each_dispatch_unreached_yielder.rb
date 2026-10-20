# A class whose `each` yields sends a boxed receiver's `each` through the
# class dispatch only where the receiver can hold that class: a box the walk
# bounds to builtins walks its Hash or Array inline, and one that can hold the
# class still reaches the class's own `each`.
class Bag
  def initialize(*xs) = @xs = xs
  def each
    @xs.each { |x| yield x }
    self
  end
end

def keys_of(h)
  out = []
  h.each { |k, v| out << [k, v] }
  out
end
p keys_of({ "a" => 1, "b" => 2 })
p keys_of({ 1 => :x })
p keys_of([[3, 4]])

def walk(x)
  out = []
  x.each { |e| out << e }
  out
end
p walk([1, 2, 3])
p walk(Bag.new(4, 5))
p walk({ "k" => "v" })
