# A block's value tested for truth where the C reads it as a condition.
# index and rindex read the value raw, so a boxed value (an element of an
# Array of mixed classes) did not build and an Integer 0, which is truthy,
# missed: [1, 2, 3].index { |x| x - 1 } answered 1. Hash#select, filter and
# reject tested the block's tail type, where a block that breaks collects
# its value boxed.

def t(k)
  log = []
  r = [1, 2, 3]
  m = [nil, 5, nil, false]
  p r.rindex { |x| x - 3 }
  p r.index { |x| x - 1 }
  p r.rindex { |x| m[x - 1] }
  p r.index { |x| m[x] }
  p r.rindex { |x| break :cut if x > 5; m[x - 1] }
  p [1.5, 2.5].rindex { |x| [x, nil][k] }

  h = {1 => 2, 3 => nil}
  p((log << :r; h).select { |key, v| log << key; break :cut if key > 5; [v, nil][k] })
  p((log << :r; h).filter { |*b| break :cut if log.size > 20; b[1] })
  p((log << :r; h).reject { |key, v| break :cut if key > 5; m[key] })
  p((log << :r; h).select { |key, v| break :cut if key > 2; v })

  p log
end

t(ARGV.size)
