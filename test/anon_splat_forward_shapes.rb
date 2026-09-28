def each_arg(*) = [*].map { |x| x * 2 }
def via_proc(pr, *, **) = pr.call(0, *, **)
def only_kw(pr, **) = pr.call(**)
def all(a, *, **, &) = nil

p each_arg(1, 2)
p via_proc(proc { |a, b, c, k:| [a, b, c, k] }, 1, 2, k: 3)
p only_kw(proc { |k:, j: 0| [k, j] }, k: 4)
p method(:all).parameters
a, * = [5, 6]
p a

def grow(*r) = r << 9
def keeps(*) = (grow(*); [*])
def keeps_named(*a) = (grow(*a); a)
p keeps(1, 2)
p keeps_named(3)
