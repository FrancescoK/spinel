# A block of each_with_index's map, select or count whose tail is typed and
# whose `next v` answers a boxed value (a local destructured from a ternary
# of Arrays): the block's value slot is the box (#9300).
def build(s)
  n, label = s ? [1, s] : [2, "y"]
  [1, 2].each_with_index.map { |x, i| next label if x > 1; "x" }
end
p build("a"), build(nil)

def nums(f)
  a, b = f ? [1, 2.5] : [3, 4]
  [10, 20, 30].each_with_index.map { |x, i| next b if i == 1; x + i }
end
p nums(true), nums(false)

def pick(s)
  _, v = s ? [0, s] : [1, nil]
  [1, 2, 3].each_with_index.select { |x, i| next v if i.zero?; x.odd? }
end
p pick("t"), pick(nil)
