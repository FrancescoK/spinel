# A block taken as `&b` and handed on more than once, or called more than once,
# receives the union of what every one of those calls passes it, not the
# first call's type alone.

def f(&b)
  [1].each(&b)
  ["s"].each(&b)
end
f { |c| p c }

def g(&)
  [2].each(&)
  [:t].each(&)
end
g { |c| p c }

def h(&b)
  b.call(1)
  b.call("s")
  b.call(1.5)
end
h { |c| p c }

def k(&b)
  p [1].map(&b)
  p ["s"].map(&b)
end
k { |c| c }
