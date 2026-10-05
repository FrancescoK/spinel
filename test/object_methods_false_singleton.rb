# obj.methods(false) / public_methods(false) / singleton_methods(false) on
# an object with singleton methods list them (and public_methods its
# class's own public methods besides), and an argument that is not a
# literal picks the list by its truth at run time. Both raised
# NoMethodError. CRuby's order is its method table's, so the lists are
# sorted.
module M
  def mm = 1
end
class K
  include M
  def a = 1
  protected def pr = 1
  private def pv = 1
end
o = K.new
def o.zz = 1
class << o
  def ww = 1
  private def xx = 1
end
p o.methods(false).sort, o.public_methods(false).sort, o.singleton_methods(false).sort
p o.methods(nil).sort, o.singleton_methods.sort
k = K.new
x = [true, false][ARGV.size + 1]
p k.methods(x), k.public_methods(x), k.singleton_methods(x)
p o.methods(x).sort, o.public_methods(x).sort, o.singleton_methods(x).sort
y = [true, false][ARGV.size]
p k.methods(y) == k.methods, o.public_methods(y) == o.public_methods, o.singleton_methods(y).sort
