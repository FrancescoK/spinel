# A private or protected method that yields or takes &block is spliced into
# the caller; called on an outside receiver it still raises NoMethodError.
class C
  def base = 7
  def cc(&b) = base(&b)
  private :cc
  def each_one = yield(1)
  private :each_one
  def pro(&b) = b ? b.call : 0
  protected :pro
  def use(o) = o.pro { 5 }
  def inner = cc
  def inner2 = each_one { |x| x + 1 }
end

begin
  C.new.cc
  p :public
rescue NoMethodError => e
  p e.message
end
begin
  C.new.each_one { |x| p x }
  p :public
rescue NoMethodError => e
  p e.message
end
begin
  v = C.new.each_one { |x| x * 3 }
  p v
rescue NoMethodError => e
  p e.message
end
begin
  C.new.pro { 2 }
  p :public
rescue NoMethodError => e
  p e.message
end
p C.new.use(C.new)
p C.new.inner
p C.new.inner2
p C.new.send(:cc)
p C.new.send(:each_one) { |x| x + 10 }

