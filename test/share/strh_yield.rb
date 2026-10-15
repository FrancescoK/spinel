# spinel: share
# spinel: gc-minor
# An Array of shared Strings a method yields is held as their handles: the
# block's parameter is the method's Array, and what the block pushes or
# changes shows in it.
def twice(a)
  yield a
  yield a
end
t = +"t"
rows = [t]
twice(rows) { |l| l << +"p"; l[0] << "!" }
p rows, t

def rows_to(s)
  a = [s, +"y"]
  yield a
  yield a
  a
end
res = rows_to(t) { |list| list << +"p"; list[0] << "?" }
p res, t, res[0].equal?(t)

def with(a)
  yield a
  a
end
r = with(rows) { it << +"i" }
r2 = with(rows) { _1 << +"n" }
p r, r2, t, rows.size

# handed through another method and a forwarded block
def inner(a)
  yield a
end
def outer(a, &blk)
  inner(a, &blk)
end
outer(rows) { |l| l << +"o"; l[0] << "." }
p rows, t

# yielded from a loop
def each_pass(a, n)
  n.times { |i| yield a, i }
end
each_pass(rows, 3) { |l, i| l << +"i#{i}" }
p rows.size
