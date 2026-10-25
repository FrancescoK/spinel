# A backtick in an instance_eval block calls self's own ` where self's class
# has one, and Kernel's (the command) on every other Object.
class A
  def `(c) = "A #{c}"
end
class B; end
class Blank < BasicObject
  def initialize; end
end

def run(o) = o.instance_eval { `echo x` }
def run_interp(o, w) = o.instance_eval { %x(echo #{w}) }

p run(A.new)
p run(B.new)
p run(3)
p run(nil)
p run(:sym)
p run_interp(A.new, "y")
p run_interp(B.new, "y")
begin
  run(Blank.new)
rescue NoMethodError => e
  p e.class
end
p [A.new, B.new].map { |o| o.instance_eval { `echo z`.size } }
p "s".instance_eval { `echo str` }
p 5.instance_eval { %x(echo #{self}) }
p [1, 2].instance_eval { `echo arr`.size + size }
