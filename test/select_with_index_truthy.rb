# select.with_index and reject.with_index test the block's value by Ruby's
# truthiness. The value was read raw as a C condition, so an Integer 0 or a
# Float 0.0, which are truthy, dropped their element:
# [0, 1, 2].select.with_index { |v, i| v } answered [1, 2]. A boxed value
# (an element of an Array holding nil) did not build.

def t(k)
  a = [0, 1, 2]
  p a.select.with_index { |v, i| v }
  p a.filter.with_index { |v, i| v }
  p a.find_all.with_index { |v, i| v }
  p a.reject.with_index { |v, i| v }
  p a.select.with_index { |v, i| i }
  p a.select.with_index(1) { |v, i| i - 1 }
  p [0.0, 1.5].select.with_index { |v, i| v }
  p [:a, :b].select.with_index { |v, i| i }
  p ["a", "b"].reject.with_index { |v, i| i }
  p (0..2).select.with_index { |v, i| v }

  m = [1, nil, 3, false]
  p m.select.with_index { |v, i| v }
  p m.reject.with_index { |v, i| v }
  p a.select.with_index { |v, i| [v, nil][k] }

  p a.select.with_index { |v, i| v > 0 }
  p a.select.with_index { |v, i| next 0 if i == 0; v > 1 }
end

t(ARGV.size)
