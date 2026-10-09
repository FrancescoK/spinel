require "set"

def walk(n, &blk)
  return if n == 0
  begin
    yield n
    walk(n - 1, &blk)
  ensure
    puts "ensure #{n}"
  end
end

def countdown(n)
  return if n == 0
  yield n
  countdown(n - 1) { |x| yield x }
end

def forward(&b) = [10, 20, 30].each(&b)

seen = []
countdown(5) { |x| break if x == 3; seen << x }
p seen
p(walk(4) { |x| break x * 100 if x == 2 })
p(forward { |x| break x + 1 if x == 20 })

[[1, 2, 3, 4], Set.new([1, 2, 3, 4])].each do |items|
  got = []
  items.each_with_index do |item, index|
    break if index == 2
    got << item
  end
  p got
  p(items.each_with_index { |item, index| break item * 10 if index == 2 })
  p(items.each_with_object([]) { |item, acc| break acc if item == 3; acc << item })
  p(items.each_slice(2) { |pair| break pair if pair.first == 3 })
end

def keep(&b)
  @kept = b
  :kept
end
p(keep { break 5 })
begin
  @kept.call
rescue LocalJumpError => e
  p e.class
end
