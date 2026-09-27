# A call carrying a `**hash` is checked against the callee's keyword
# params as CRuby checks it: a required keyword neither a literal key nor
# the hash supplies is missing, and a key (literal or from the hash) naming
# no parameter is unknown.

def try
  p yield
rescue ArgumentError => ex
  p ex.message
end

def req(k:) = k
h = { k: 1 }
try { req(**h) }
try { req(**{}) }
e = {}
try { req(**e) }
gone = { k: 1 }
gone.delete(:k)
try { req(**gone) }

def req2(a, k:, j:) = [a, k, j]
try { req2(1, k: 2, **gone) }
try { req2(1, **gone) }
try { req2(1, j: 3, **h) }

def req_rest(k:, **o) = [k, o]
z = { z: 1 }
try { req_rest(**z) }
try { req_rest(k: 2, **z) }

def opt(k: 1) = k
try { opt(z: 2, **{ k: 3 }) }
try { opt(z: 2, **h) }
try { opt(z: 2, **e) }
try { opt(z: 2, y: 4, **{ x: 5 }) }

def two(k: 1, j: 2) = [k, j]
try { two(j: 5, **h) }

class C
  def req(k:) = k
  def opt(k: 1) = k
end
try { C.new.req(**gone) }
try { C.new.opt(z: 2, **h) }

# a hash only known at run time
boxed = [{ z: 2 }, 1]
try { opt(**boxed[0]) }
try { C.new.opt(**boxed[0]) }
ok = [{ k: 5 }, 1]
try { opt(**ok[0]) }
try { req(**boxed[0]) }
