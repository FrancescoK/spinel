# A dispatch alias can return a borrowed String from a differently named
# method: the element is that String itself, beside a method's new String,
# and a change through the element shows in the String it borrows.
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
