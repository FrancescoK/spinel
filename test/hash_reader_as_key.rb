# an object whose hash is a reader (`attr_reader :hash`) and whose class
# defines eql?: as a Hash key and in uniq it is hashed by that reader, as a
# def of hash would be

class R
  attr_reader :hash
  def initialize(h) = @hash = h
  def eql?(o) = o.is_a?(R) && o.hash == @hash
end

g = { R.new(5) => :b }
p g[R.new(5)]
p g[R.new(6)]
p [R.new(3), R.new(3), R.new(4)].uniq.size
p g.key?(R.new(5))

class N
  attr_reader :hash
  def initialize(h) = @hash = h
  def eql?(o) = true
end
p(({ N.new(nil) => 1 } rescue "#{$!.class}"))
p({ N.new(2) => 1 }[N.new(2)])
