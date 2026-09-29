# Small methods that each call the next six times: forcing every one of them
# inline asked the C compiler for thousands of copies of the innermost, and
# the build took minutes. infer-test checks the chain's top is not forced.
def g(h)
  h[:k] = 1
  h
end
def f0(x) = g(x)
def f1(x)
  f0(x)
  f0(x)
  f0(x)
  f0(x)
  f0(x)
  f0(x)
end
def f2(x)
  f1(x)
  f1(x)
  f1(x)
  f1(x)
  f1(x)
  f1(x)
end
def f3(x)
  f2(x)
  f2(x)
  f2(x)
  f2(x)
  f2(x)
  f2(x)
end
def f4(x)
  f3(x)
  f3(x)
  f3(x)
  f3(x)
  f3(x)
  f3(x)
end
def f5(x)
  f4(x)
  f4(x)
  f4(x)
  f4(x)
  f4(x)
  f4(x)
end
def f6(x)
  f5(x)
  f5(x)
  f5(x)
  f5(x)
  f5(x)
  f5(x)
end
p f6({"a" => 0}).size
