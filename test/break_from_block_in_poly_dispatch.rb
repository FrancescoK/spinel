Pair = Struct.new(:a, :b)

def pick(n)
  n.zero? ? [10, 20, 30, 40] : Pair.new(:x, :y)
end

[0, 1].each do |n|
  items = pick(n)
  seen = []
  items.each_with_index do |item, index|
    break if index == 1
    seen << item
  end
  p seen

  found = items.each_with_index { |item, index| break [item, index] if index == 1 }
  p found

  acc = items.each_with_object([]) do |item, memo|
    break memo if memo.size == 1
    memo << item
  end
  p acc

  slices = []
  items.each_slice(1) do |slice|
    break if slices.size == 1
    slices << slice
  end
  p slices

  p(items&.each_with_index { |_item, index| break :safe if index.zero? })
end

def with_deadline(log)
  yield
ensure
  log << :ensure
end

log = []
value = with_deadline(log) do
  pick(1).each_with_index do |item, index|
    begin
      break item if index == 1
    ensure
      log << index
    end
  end
end
p value
p log
