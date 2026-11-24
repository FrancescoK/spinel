# CRuby's pp lists an object's ivars sorted by name (its
# pretty_print_instance_variables is instance_variables.sort), in an Array,
# a Hash or another object too; p and inspect keep the order of their first
# assignment. An object whose class has its own #inspect prints by it.
require "tmpdir"
class C; attr_accessor :m, :n; end
class U; def initialize; @z = 1; @a = C.new; @a.n = 1; @a.m = 2; end; def inspect = "U(#{@a.inspect})"; end
class N; def initialize(k); @k = k; @b = C.new; @b.n = 3; @b.m = 4; @a = 0; end; end
class P; def initialize; @y = 1; @x = 2; end; end
class Q; def initialize(f); @w = 1 if f; @v = 2; @u = 3 if !f; end; end
class D; def initialize; @b = 1; @a = 2; end; end
class DD < D; def initialize; super; @aa = 3; @ab = 0; end; end
c = C.new; c.n = 1; c.m = 2
path = File.join(Dir.tmpdir, "pp_lists_ivars_by_name_#{Process.pid}.txt")
saved = $stdout.dup
$stdout.reopen(path, "w")
pp c
pp U.new
pp N.new(:k)
pp({a: c})
pp [P.new, 1]
pp c, P.new
r = pp(P.new, c)
p r
p c
pp Q.new(true), Q.new(false)
x = pp(c)
p x.equal?(c)
def show(o) = pp(o)
show(N.new(1))
pp DD.new
def ppy = pp(yield)
ppy { DD.new }
ppy { [1, D.new] }
$stdout.flush
$stdout.reopen(saved)
puts File.read(path).gsub(/0x\h+/, "0x")
File.delete(path)
