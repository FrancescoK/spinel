# A `&x` block argument whose value is no Proc, nil, Method, Symbol or
# Hash raises TypeError before the call runs, whatever the method does
# with its block: index/find_index with a value ignore it, and the splat
# forms dispatch on the count. Only nil passes no block.
def t
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

class Plain; end

def mk(v)
  puts "mk #{v}"
  v
end

f = false
n = 5
pl = Plain.new
pr = proc { |x| x == 6 }
nl = nil
e0 = []
e1 = [6]
pf = [false, pr][0]
pi = [1, pr][0]
po = [pr, 1][0]

t { p [5, 6].index(6, &f) }
t { p [5, 6].find_index(6, &n) }
t { p [5, 6].rindex(6, &pl) }
t { p [5, 6].index(6, &Object.new) }
t { p [5, 6].count(6, &Plain.new) }
t { p [5, "a"].index("a", &f) }
t { p (1..3).find_index(2, &f) }
t { p [5, 6].find_index(*e1, &f) }
t { p [5, 6].find_index(*e0, &f) }
t { p [5, 6].index(*e1, &pl) }
t { p [5, 6].each.find_index(*e1, &f) }
t { p [5, 6].index(6, &pf) }
t { p [5, 6].index(6, &pi) }
t { p [5, 6].count(&f) }
t { p [5, 6].sum(&1.5) }
t { p [5, 6].select(&f) }
t { p [3].tap(&f) }
t { p [5, 6].index(mk(6), &f) }
t { x = [5, 6].index(6, &f).to_i + 1; p x }

# nil, a Proc, a Method, a Symbol and a Hash become blocks
p [5, 6].index(6, &nl)
p [5, 6].index(6, &pr)
p [5, 6].index(&po)
p [5, 6].find_index(*e1, &pr)
p [5, 6].find_index(*e0, &pr)
p [5, 6].index(*e1, &nl)
p [5, 6].index(&6.method(:==))
p [5, 6].map(&:even?)
p [5, 6].map(&{ 6 => true })
p nil&.foo(&f)
