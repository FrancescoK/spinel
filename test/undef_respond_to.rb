class C; def gone = 2; def kept = 3; undef gone; end
p C.new.respond_to?(:gone)
p C.new.respond_to?(:kept)
p C.method_defined?(:gone)
p C.instance_methods(false).sort
p C.public_method_defined?(:gone)
class P; def z = 1; end
class R < P; undef z; end
p R.new.respond_to?(:z)
p R.method_defined?(:z)
p P.new.respond_to?(:z)
class C2
  def gone = 2
  def kept = 3
  undef gone
  def probe = respond_to?(:gone)
end
class D
  attr_accessor :w
  undef w=
end
class E
  def gone = 1
  def respond_to?(m, all = false) = super
end
class E; undef gone; end
p C2.new.probe
p D.new.respond_to?(:w=), D.new.respond_to?(:w)
p D.method_defined?(:w=)
p E.new.respond_to?(:gone)
xs = [C2.new, 1, "s"]
xs.each { |x| p x.respond_to?(:gone) }
c = C2.new
if c.respond_to?(:gone) then puts "yes" else puts "no" end
p C2.private_method_defined?(:gone), C2.method_defined?(:gone, false)
