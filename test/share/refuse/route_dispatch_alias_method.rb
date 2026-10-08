# A dispatch alias can return a borrowed String from a differently named method.
class FreshResult
  def initialize(text) = @text = text
  def plus = @text + "a"
end
class BorrowedResult
  def initialize(text) = @text = text
  def get = @text
  alias_method :plus, :get
end
source = +"s"
receivers = [FreshResult.new(+"s"), BorrowedResult.new(source)]
values = [receivers[1].plus, receivers[0].plus]
values[0] << "!"
p values, source
