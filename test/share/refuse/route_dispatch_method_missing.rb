# A missing method can return a borrowed String instead of raising.
class FreshResult
  def initialize(text) = @text = text
  def plus = @text + "a"
end
class BorrowedResult
  def initialize(text) = @text = text
  def method_missing(name, *args) = @text
  def respond_to_missing?(*) = true
end
source = +"s"
receivers = [FreshResult.new(+"s"), BorrowedResult.new(source)]
values = [receivers[0].plus, receivers[1].plus]
values[1] << "!"
p values, source
