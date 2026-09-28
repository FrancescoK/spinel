# instance_exec / instance_eval on a boxed receiver whose body only touches
# ivars, and on builtin receivers the block-splice declines (keyword splats).

class Foo; def initialize; @v = 9; end; attr_reader :v; end
class Bar; def initialize; @v = 7; end; attr_reader :v; end
class Baz; def initialize; @v = "s"; end; end

# a boxed receiver reads each class's own ivar
[Foo.new, Bar.new].each { |x| p x.instance_exec(5) { |a| [a, @v] } }
[Foo.new, Baz.new].each { |x| p x.instance_exec(5) { |a| [a, @v] } }
[Foo.new, Baz.new].each { |x| p x.instance_eval { @v } }

# builtins mixed in read nil
[1, Foo.new, "q"].each { |x| p x.instance_exec(1) { |a| [@v, a] } }

# writes land on each receiver
xs = [Foo.new, Bar.new]
xs.each { |x| x.instance_exec(2) { |a| @v = @v * a } }
p xs.map(&:v)
xs.each { |x| x.instance_exec("w") { |a| @v = a } }
p xs.map(&:v)

# from an instance method and a class method
class Holder
  def initialize(xs) = @xs = xs
  def run = @xs.map { |x| x.instance_eval { @v } }
  def self.run(xs) = xs.map { |x| x.instance_exec(3) { |a| @v + a } }
end
p Holder.new([Foo.new, Bar.new]).run
p Holder.run([Foo.new, Bar.new])

# builtin receivers with a keyword splat: self is the receiver
h = {k: 3}
arr = [1, 2]
p arr.instance_exec(5, **h) { |a, k: 1| length }
p [1, 2].instance_exec(5, **h) { |a, k: 1| [a, k] }
p "abc".instance_exec(5, **h) { |a, k: 1| [a, k, upcase, size] }
p({x: 1}.instance_exec(5, **h) { |a, k: 1| [a, k, keys] })
p (1..4).instance_exec(**h) { |k: 1| [k, sum] }
p [3, 1, 2].instance_exec(1, 2, 3, **h) { |a, *r, k: 1| [a, r, k, sort] }
p [4, 5].instance_exec(7, [8].map { |v| v }, **h) { |a, *r, k: 1| [a, r, k, last] }
