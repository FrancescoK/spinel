# A yielding method called inside its own block answers the inner call's
# value, and Kernel#p handing a yield's value on answers each call site's
# block value, whatever the other sites' blocks answer.
def tw
  p(yield)
end
p tw { tw { tw { 1.5 } } }
p tw { [1, 2] }
p [tw { 1 }, tw { "x" }]
p tw { tw { nil } }.nil?

def try
  p yield
rescue NoMethodError => e
  [e.class]
end
p try { try { 1 } }
p try { "s" }
p [try { 2 }, try { try { try { 3 } } }]

def en
  r = pp(yield)
  r
ensure
  puts "e"
end
p en { en { 7 } }
p en { "z" }

def a1 = b1 { yield }
def b1 = p(yield)
p a1 { b1 { 4 } }
p a1 { "s" }

def gv
  yield
end
p gv { tw { gv { "q" } } }
