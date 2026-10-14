# A class whose object the program hands out -- read into a variable,
# answered by its own class method, frozen, tapped, through a constant
# alias, as self in a class_eval block, as self in a module it extends or in
# its `class << self` body, or answered by private_class_method or
# public_class_method (which answer their receiver) -- can be held by a box, and a boxed call then
# reaches its class method: the String it answers is the one that method
# keeps, and a change through the answer shows through it.
$all = []
b = +"buf"; $all << b; b << "!"
class Obj
  def tag(a) = +"obj"
end
def run(x)
  pr = x.tag(1)
  $all << pr
  pr << "?"
  pr
end
class C1; def self.tag(a) = ($k1 ||= +"k1"); end
m = C1
p run([m, Obj.new][ARGV.size])
class C2; def self.tag(a) = ($k2 ||= +"k2"); def self.me = self; end
p run([C2.me, Obj.new][ARGV.size])
class C3; def self.tag(a) = ($k3 ||= +"k3"); end
p run([C3.freeze, Obj.new][ARGV.size])
class C4; def self.tag(a) = ($k4 ||= +"k4"); end
$t4 = nil
C4.tap { |k| $t4 = k }
p run([$t4, Obj.new][ARGV.size])
class C7; def self.tag(a) = ($k7 ||= +"k7"); end
Alias7 = C7
p run([Alias7, Obj.new][ARGV.size])
class C8; def self.tag(a) = ($k8 ||= +"k8"); end
$t8 = nil
C8.class_eval { $t8 = self }
p run([$t8, Obj.new][ARGV.size])
module Me
  def me = self
end
class C9
  extend Me
  def self.tag(a) = ($k9 ||= +"k9")
end
p run([C9.me, Obj.new][ARGV.size])
class C10
  class << self
    def me = self
  end
  def self.tag(a) = ($k10 ||= +"k10")
end
p run([C10.me, Obj.new][ARGV.size])
class C11
  def self.tag(a) = ($k11 ||= +"k11")
  def self.helper = 1
  Me11 = private_class_method(:helper)
end
p run([C11::Me11, Obj.new][ARGV.size])
class C12
  def self.tag(a) = ($k12 ||= +"k12")
  def self.helper = 1
  Me12 = public_class_method(:helper)
end
p run([C12::Me12, Obj.new][ARGV.size])
p $k1, $k2, $k3, $k4, $k7, $k8, $k9, $k10, $k11, $k12
p $all
