class Base
  def on(&handler) = @handler = handler
  def fire(v) = @handler.call(v)
end
class A < Base
  def on(&) = super(&)
end
count = 0
a = A.new
a.on { |v| count += v }
a.fire(3)
a.fire(4)
p count
