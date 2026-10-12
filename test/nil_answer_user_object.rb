# A call nil has of its own, on a user object that may be nil: the method
# runs for a non-nil receiver and NilClass answers for a nil one (#7444),
# where its answer has the call's type: to_s "", inspect "nil", == and eql?
# by the argument's nil, nil? true, hash nil's, is_a? by the class, and an
# interpolated part reads as "". The receiver and the arguments run in
# Ruby's order, once.
class Box
  def initialize(v) = @v = v
  def to_s = "box#{@v}"
  def inspect = "<B>"
  def ==(o) = o.is_a?(Box)
  def eql?(o) = o.is_a?(Box)
  def hash = 7
  def nil? = false
  def frozen? = false
end
def pick(n)
  case n
  when 1 then Box.new(1)
  end
end
[1, 2].each do |n|
  b = pick(n)
  p b.to_s
  p b.inspect
  p b == Box.new(2)
  p b == nil
  p b != nil
  p b.eql?(Box.new(3))
  p b.nil?
  p b.hash == 7, b.hash == nil.hash
  p b.frozen?
  p b.is_a?(Box), b.is_a?(NilClass), b.kind_of?(Object)
  puts "#{b}|"
end
def arg
  puts "arg evaluated"
  Box.new(9)
end
p pick(2) == arg
