# A `klass.new` on a class chosen at run time keeps every class
# instantiable; main's ivars live on the Toplevel pseudo-class, which is not
# one of them (it has no struct, so its GC scanner does not exist).
class A
  def initialize(v = 1) = @v = v
end
class B
  def initialize(v = 2) = @v = v
end
@top = [1, "a"]
def reg = [A, B]
kl = reg[ARGV.size]
o = kl.new
p o.class, @top
