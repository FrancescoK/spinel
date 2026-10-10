# A bare `next` in a block given to with_index on an Enumerator object (a
# map over a boxed receiver, a stored Enumerator) collects nil.

def items(x) = x ? [1, 2, 3] : {}

def t(k)
  p items(true).map.with_index { |v, i| next if v == 2; v }
  p items(true).map.with_index { |v, i| next if i == 0; v }
  p items(true).map.with_index { |v, i| next if v.odd?; v }
  p items(true).map.with_index(1) { |v, i| next if i == 2; v * 10 }
  p items(true).collect.with_index { |v, i| next if v == 2; v }
  p items(true).map.with_index { |v, i| next if v == 2; [v, i] }
  e = [1, 2, 3].map
  p e.with_index { |v, i| next if v == 2; v }

  p items(true).map.with_index { |v, i| next v * 100 if v == 2; v }
  p items(true).map.with_index { |v, i| v if v != 2 }
  p [1, 2, 3].each.with_index { |v, i| next if v == 2; v }
end

t(ARGV.size)
