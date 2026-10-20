# A `return` in a block that an iterator written in Ruby runs (find,
# each_with_index) leaves the method the block is written in, so its value
# takes that method's return slot, not the iterator's own (find answers an
# element or nil: an Integer with its nil).
def hit?(xs, stop, want)
  xs.find do |x|
    break if x == stop
    next if x.odd?
    return true if x == want
  end
  false
end

def scaled(xs, stop)
  xs.find do |x|
    break if x == stop
    return x * 10 if x > 2
  end
  -1
end

def index_of_hit(xs)
  xs.each_with_index do |x, i|
    break if x.nil?
    return i if x == :hit
  end
  nil
end

def first_big(xs)
  xs.find do |x|
    return "big #{x}" if x > 100
  end
  "small"
end

p hit?([2, 4, 6], 99, 4), hit?([2, 4, 6], 4, 6), hit?([1, 3], 0, 0)
p scaled([1, 2, 4, 6], 99), scaled([1, 3, 2, 9], 9), scaled([5], 5)
p index_of_hit([:a, :hit]), index_of_hit([:a, nil, :hit]), index_of_hit([])
p first_big([1, 200]), first_big([1, 2])
