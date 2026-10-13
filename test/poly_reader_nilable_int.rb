# A reader of an Integer ivar that may be nil, reached through a dispatch on
# a value of several classes: the arm boxes the ivar with its nil, as the
# call plan says (--plan-check: no poly-conflict).

class A
  attr_reader :v
  def initialize = @v = nil
  def set = @v = 3
end
class B
  def v = 7
end
a = A.new
a.set if ARGV.size > 5
xs = [a, B.new]
xs.each { |x| y = x.v; p y }
t = xs.map { |x| x.v }
p t

class Ra
  attr_reader :v
  def initialize(v) = @v = v
end
class Rb
  def v = "s"
end
xs = [Ra.new(1), Ra.new(nil), Rb.new]
xs.each { |x| p x.v }
