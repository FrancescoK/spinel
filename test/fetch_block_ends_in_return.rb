# A fetch block that ends in `return` leaves the method from the block, so
# the fetch has no value there.
class Seen
  def initialize = @seen = {}

  def repeated?(name, node)
    seen = @seen.fetch(name) do
      @seen[name] = node
      return false
    end
    !seen.equal?(node)
  end
end

d = Seen.new
a = Object.new
b = Object.new
p d.repeated?(:x, a), d.repeated?(:x, a), d.repeated?(:x, b), d.repeated?(:y, b)

COUNTS = { "a" => 1 }
def count_of(k) = COUNTS.fetch(k) { return -1 } * 10
p count_of("a"), count_of("b")

def first_known(keys)
  keys.each do |k|
    v = COUNTS.fetch(k) { next }
    return v
  end
  nil
end
p first_known(%w[x a]), first_known(%w[y])

def at(list, i)
  list.fetch(i) do
    return "none" if i > 5
    :near
  end
end
p at([1, 2], 0), at([1, 2], 3), at([1, 2], 9)

def guarded(h, k)
  h.fetch(k) { return :missing }
ensure
  puts "ensure #{k}"
end
p guarded({ q: 1 }, :q), guarded({}, :z)

# an Array's fetch block that ends in return, typed and with its nil
def arr_first_or(xs) = xs.fetch(0) { return -1 }
def arr_scaled(xs, i) = xs.fetch(i) { |j| return j * 10 }
def arr_maybe(xs, i)
  v = xs.fetch(i) { |j| return nil if j > 5; 7 }
  v + 1
end
p arr_first_or([]), arr_first_or([5]), arr_scaled([1], 3)
p arr_maybe([1], 9), arr_maybe([1], 3), arr_maybe([1, 2], 1)
