# Delegated conditions keep the target's return form and the receiver's nil arm.
class ViewAnswer
  def initialize(v) = @v = v
  def ==(other) = @v
end
class ViewChild < ViewAnswer; end
[ViewAnswer.new(nil), ViewAnswer.new(0)].each do |x|
  p(x != ViewAnswer.new(1))
  p(x === ViewAnswer.new(1))
  p(x === x)
end
x = ViewChild.new(0)
p(x === ViewAnswer.new(1))
p(x != ViewAnswer.new(1))
a = [ViewAnswer.new(0)]
p(a[1] === nil)
p(a[1] != nil)
p(nil === nil)
class ViewOwn
  def ==(other) = nil
  def !=(other) = :own
  def ===(other) = :case_own
end
[ViewAnswer.new(0), ViewOwn.new].each do |v|
  p(v != v)
  p(v === v)
end
