# inject / reduce without a block, given its operator only at run time: a
# Symbol or a String names it, and anything else is CRuby's TypeError

def msg = "#{$!.class}: #{$!.message}"

def f(a, x) = a.inject(x)
p((f([1, 2], 5) rescue msg))

def g(a, x) = a.inject(x)
p g([1, 2, 3], :+)
p g([1, 2, 3], "*")
p((g([1, 2], 5) rescue msg))

def s(a, i, x) = a.reduce(i, x)
p s([1, 2], 10, "+")
p s([1, 2], 10, :-)

def ws(a, x) = a.inject(x)
p ws(%w[a b], "+")
def wf(a, x) = a.inject(x)
p wf([1.5, 2.5], :+)

p(([1, 2].inject(5) rescue msg))
p(([1, 2].inject(nil) rescue msg))
p(([1, 2].inject(1, 2) rescue msg))
p(([1, 2].inject([]) rescue msg))
