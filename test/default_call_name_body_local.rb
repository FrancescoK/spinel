# A parameter default that calls a method named like a local of the method
# body declares nothing for it: only its own locals and block parameters are
# declared at the call site.

def f(a, b = a.size)
  size = 3
  size + b
end
p f("xy")

def g(a:, b: a.length + count)
  count = 10
  length = 20
  [count, length, b]
end
def count = 1
p g(a: "abc")

def h(a, b = [a].map { _1 * 2 }.first, c = [[a, 1]].map { |(v, i)| v + i }.first) = [a, b, c]
p h(4)

def r(a, b = begin; Integer(a); rescue => e; e.class; end) = [a, b]
p r("zz")
e = "caller e"
p e
