# A yielding method that keeps its block, and so is called as a function,
# hands its String parameter on to a method that appends to it: the append
# reaches the caller's String.
# spinel: gc-minor
# spinel: share
def grow(v) = v << "x"
def keep(p1, &kb)
  @kb = kb
  grow(p1)
  yield
  p1.size
end
v = +"s1"
p keep(v) { 1 }
p v
p @kb.call

def keep_kw(p1, k: 1, &kb)
  @kb2 = kb
  grow(p1)
  yield(k)
end
w = +"t1"
p keep_kw(w, k: 2) { |x| x }
p w
