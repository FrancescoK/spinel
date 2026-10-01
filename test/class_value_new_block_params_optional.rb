# A block a class value's `new` hands to one of two initialize methods that
# yield different types: its optional, post and keyword parameters are
# boxed like its required ones, since neither initialize types them alone.
class A; def initialize = yield(5); end
class B; def initialize = yield([7]); end
k = [A, B][ARGV.size]
k.new { |t = []| p(t << 1) }
k2 = [B, A][ARGV.size]
k2.new { |t = []| p(t << 1) }

class E; def initialize = yield(5, k: 3); end
class F; def initialize = yield(1, k: [7]); end
e = [E, F][ARGV.size]
e.new { |x, k: []| p(k << x) }
e2 = [F, E][ARGV.size]
e2.new { |x, k: []| p(k << x) }

class C; def initialize = yield(1, 2, 3); end
class D; def initialize = yield("s", "u"); end
m = [C, D][ARGV.size]
m.new { |a, b = 0, *r, z| p [a, b, r, z] }
m2 = [D, C][ARGV.size]
m2.new { |a, b = 0, *r, z| p [a, b, r, z] }
