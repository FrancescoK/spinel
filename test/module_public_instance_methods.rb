# Mod.public_instance_methods / instance_methods with the inherited ones
# lists the module's own methods and those of the modules it includes,
# each with the visibility and undef the first of them in lookup order
# gives it. A constant path (Outer::Mod) names the module too.
module Inner
  def i1; end
  private def i2; end
  attr_accessor :ia
end
module Ns
  module Outer
    include Inner
    def o1; end
    alias_method :o2, :o1
    protected def o3; end
  end
  class Kl
    def k1; end
  end
end
module Inner
  def late; end
  private :ia
end
module Ns::Outer
  public :i2
end
module Und
  include Inner
  undef_method :i1
  def u1; end
end
module Ff
  module_function
  def mf; end
end
module A
  module M
    def am; end
  end
end
module B
  module M
    def bm; end
  end
end
module Empty; end

p Ns::Outer.public_instance_methods.sort
p Ns::Outer.instance_methods.sort
p Ns::Outer.public_instance_methods(true).sort
p Inner.public_instance_methods.sort
p Und.public_instance_methods.sort
p Ff.public_instance_methods
p Empty.public_instance_methods
p [A::M.public_instance_methods, B::M.instance_methods]
p Ns::Kl.public_instance_methods.include?(:k1)
methods = Ns::Outer.public_instance_methods.map(&:to_s)
p methods.grep(/^i/).sort.map { |n| n.sub(/^i/, "o") } - methods

# a visibility line for an included method makes the module's own copy
module A1
  def a; end
  def a2; end
end
module B1
  include A1
  private :a
  def b; end
end
p [B1.public_instance_methods.sort, B1.private_instance_methods(false), B1.instance_methods(false).sort]
