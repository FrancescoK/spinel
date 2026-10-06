# merge with several arguments, or with a block, on a boxed receiver that
# is no Hash: CRuby runs the receiver and every argument, then raises
# NoMethodError with all of them as its args. The fold into
# h.merge(a).merge(b) raised at its first link, and a block merge took
# nil as an empty Hash.

def f(x)
  puts "f#{x}"
  {%i[k0 k1 k2 k3 k4 k5 k6 k7 k8 k9 k10 k11 k12 k13 k14][x] => x}
end

def t
  yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
end

def fw(h, &blk) = h.merge(f(10), &blk)

[[nil, {a: 1}], [5, {a: 1}], [{a: 1}, nil]].each do |pair|
  h = pair[ARGV.size]
  t { p h.merge(f(1), f(2)) }
  t { p h.merge({b: 2}, {c: 3}, {d: 4}) }
  t { p h.merge!({e: 3}, {f: 4}) }
  t { p h.merge(f(7), f(8)) { |k, a, b| a } }
  t { p h.merge(f(9)) { |k, a, b| a } }
  t { p fw(h) { |k, a, b| a } }
  pr = proc { |k, a, b| b }
  t { p h.merge(f(11), &pr) }
  t { p h.merge(f(12), &nil) }
end
