# A block a recursive yielder lifts into a proc keeps the static types the
# enclosing method gave its parameters. Its optional, keyword and `**rest`
# params were bound as boxed values regardless, and the body that read them
# as those types did not compile.

def ry(n, h)
  return yield(n, **h) if n == 0
  ry(n - 1, h) { |a, **o| yield a, **o }
end
ry(1, { q: 2 }) { |a, q:| p [a, q] }      #=> [0, 2]

def rw(n)
  return yield(n) if n == 0
  rw(n - 1) { |a, b = 5| yield a + b }
end
rw(1) { |x| p x }                          #=> 5

def rk(n)
  return yield(n, k: 3) if n == 0
  rk(n - 1) { |a, k: 0| yield a + k, k: k }
end
rk(1) { |x, k:| p [x, k] }                 #=> [3, 3]

def rs(n)
  return yield(n, s: "x") if n == 0
  rs(n - 1) { |a, s: "d"| yield a, s: s + "!" }
end
rs(1) { |a, s:| p [a, s] }                 #=> [0, "x!"]
