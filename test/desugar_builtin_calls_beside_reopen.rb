# the calls a desugar writes to spread a yielded Array over a block's
# parameters, or to check a splat's count, are the builtins' own: an Array
# reopened with its own length, size or [] does not change how many values
# a block or a method takes

class Array
  def length = 0
  def size = 0
  def [](*) = :reopened
end

[[1, 2]].each { |a, b = 5| p [a, b] }
[[1, 2, 3, 4]].each { |a, *r, z| p [a, r, z] }

def m(a, b) = a + b
p m(*Array.new(2) { |i| i + 1 })
begin; m(*Array.new(3) { |i| i }); rescue ArgumentError => e; puts e.message; end
p "ab".center(*Array.new(1) { 6 })
begin; "ab".center(*Array.new(3) { 6 }); rescue ArgumentError => e; puts e.message; end
