class B
  def go(a, b = 3) = yield(a + b)
end
class S < B
  def go(...) = super(...)
end
p S.new.go(1) { |x| x * 2 }
p S.new.go(1, 5) { |x| x * 2 }
