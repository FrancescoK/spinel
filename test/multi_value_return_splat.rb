# `return *a, b`, `break`/`next` with several values, and `yield` /
# `blk.call` with a splat among other arguments splice the splat.

def r1; e = [1, 2]; return *e, 5; end; p r1
def r2; e = [1, 2]; return 5, *e; end; p r2
def r3; e = [1, 2]; return *e; end; p r3
def r4; return *[]; end; p r4
def r5; e = ["a", "b"]; return *e, "c"; end; p r5
def r6; e = [1.5]; return 0.5, *e; end; p r6
def r7(*r); return *r, 9; end; p r7(1, 2); p r7
def r8; e = [1, 2]; begin; return *e, "x"; ensure; p :ens; end; end; p r8
l = lambda { e = [1, 2]; return *e, 3 }; p l.call
x, y, z = r7(7, 8); p [x, y, z]

p([1].map { |_| e = [1, 2]; next *e, 5 })
p([1].map { |_| next 1, 2 })
p([1, 2].each_with_index.map { |v, i| next v, i })
p([1].each { |_| e = [1, 2]; break *e, 5 })
p(loop { e = ["q"]; break *e, 1 })

def y1; e = []; yield(*e, 7); end; y1 { |q, w| p [q, w] }
def y2; e = [1, 2]; yield(*e, 7); end; y2 { |q, w, z| p [q, w, z] }
def y3; e = [1, 2]; yield 7, *e; end; y3 { |q, w, z| p [q, w, z] }
def y4; e = [1.5, 2.5]; yield(*e, *e); end; y4 { |*a| p a }
def y5; e = [1, 2]; yield(*e, 3); end; p(y5 { |q, w, z| q + w + z })
def c1(&b); e = [1, 2]; b.call(*e, 7); end; c1 { |q, w, z| p [q, w, z] }
def c2(&b); e = [1, 2]; b.call(7, *e); end; c2 { |q, w, z| p [q, w, z] }
class A; def call(a, b, c); p [a, b, c]; end; end
A.new.call(*[1, 2], 3)
