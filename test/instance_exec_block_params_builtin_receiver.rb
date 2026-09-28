# Keyword, optional and rest block parameters of instance_exec on a receiver
# that is not a user object: a plain Object, a String, an Array, an Integer.
o = Object.new
p o.instance_exec(5, k: 2) { |a, k: 1| [a, k] }
p o.instance_exec(5) { |a, k: 1| [a, k] }
p o.instance_exec(5, k: 2, j: 3) { |a, **r| [a, r] }
p o.instance_exec(5) { |a, **r| [a, r] }
p o.instance_exec(5, 6, k: 2) { |a, *r, k: 1| [a, r, k] }
p o.instance_exec(5) { |a, b = 3| [a, b] }
p o.instance_exec(5, 6, 7) { |a, *r| [a, r] }
p o.instance_eval { |s, k: 4| k }
h = {k: 8}
p o.instance_exec(5, **h) { |a, k: 1| [a, k] }
begin
  o.instance_exec(5, z: 1) { |a, k: 1| [a, k] }
rescue ArgumentError => e
  p e.message
end

s = "str"
p s.instance_exec(5) { |a, k: 1| [a, k] }
p s.instance_exec(5) { |a, k: 1| [a, k, size] }
p s.instance_exec(5, k: 2) { |a, k: 1| [a, k, size] }
p s.instance_exec(5) { |a, b = 3| [a, b] }
p s.instance_exec(5, 6) { |a, b = 3| [a, b, size] }
p s.instance_exec(5) { |a, b = (a + size)| b }
p s.instance_exec(5) { |a, k: size| k }
p s.instance_exec(5, j: 1, k: 2) { |a, k: 0, j: 9| [a, k, j] }
p s.instance_exec(5) { |a, *r| [a, r] }
p s.instance_exec(5, 6, 7) { |a, *r| [a, r] }
p s.instance_exec(5, **h) { |a, k: 1| [a, k] }
x = 1
p s.instance_exec(5) { |a, k: x| [a, k] }
begin
  s.instance_exec(5) { |a, k:| [a, k] }
rescue ArgumentError => e
  p e.message
end

p 4.instance_exec(5) { |a, **r| [a, r] }
p 4.instance_exec(5, k: 1) { |a, **r| [a, r] }
p 4.instance_exec(k: 1) { |k:| k + self }
p [1, 2].instance_exec(k: 3) { |k: 1| [k, length] }
p({a: 1}.instance_exec(k: 3) { |k: 1| [k, size] })

class Foo
  def initialize; @v = 9; end
  def run = instance_exec(5, k: 2) { |a, k: 1| [a, k, @v] }
end
f = Foo.new
p f.run
p f.instance_exec(5) { |a, b = 3| [a, b, @v] }
p f.instance_exec(5, k: 2, j: 3) { |a, **r| [a, r] }
