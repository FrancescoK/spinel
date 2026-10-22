# min, max and minmax with a block on an index Enumerator compare two of its
# [element, index] pairs, as sort's block does (index_enum_sort_block.rb), and
# were refused at compile time the same way. The array is routed through a
# method so it is not constant-folded at the call site.

def params
  ["b=2", "a=1", "a=0", "a=1", "c"]
end

p params.each.with_index.min { |a, b| a <=> b }
p params.each_with_index.max { |a, b| a <=> b }
p params.map.with_index.min { |a, b| b <=> a }
p params.each.with_index(1).max { |a, b| a[1] <=> b[1] }
p params.each.with_index.minmax { |a, b| a <=> b }
