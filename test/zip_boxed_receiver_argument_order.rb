# Even a receiver without zip evaluates all operands before method lookup.
# spinel: gc-minor
recv = [nil, [1]][0]
items = []
begin
  recv.zip((items << 1), []) { |row| p row }
rescue NoMethodError
  p items
end
items = []
begin
  recv.zip(items << 2) { |row| p row }
rescue NoMethodError
  p items
end

def operand(items, n)
  items << n
  [n, "x"][0]
end
items = []
begin
  recv.zip(operand(items, 3)) { |row| p row }
rescue NoMethodError
  p items
end
items = []
begin
  recv.zip((items << 4), (raise "argument")) { |row| p row }
rescue RuntimeError => e
  p e.message, items
end
recv = [[1, 2], nil][0]
items = []
recv.zip(items << 5) { |a, b| p a, b }
p items
