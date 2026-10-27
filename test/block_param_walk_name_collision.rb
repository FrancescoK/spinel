# A block parameter that walks an Array of one class takes that class
# whatever the other locals of its scope are called. The test for "nothing
# else writes it" read the (scope, name) write index's bucket, which also
# holds the writes of names whose hash collides: `ftcf` shares a bucket
# with the parameter here, and its write boxed the parameter. (infer-test
# checks the parameter's C type.)
class Pt
  attr_reader :x
  def initialize(x)
    @x = x
  end
end
xs = [Pt.new(1), Pt.new(2)]
ftcf = 5
xs.each_with_index { |pt, i| puts pt.x + ftcf + i }
puts xs.map { |pt| pt.x }.sum
