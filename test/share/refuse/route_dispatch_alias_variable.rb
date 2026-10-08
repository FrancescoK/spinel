# A dispatch alias can return a borrowed String from a differently named method.
class FreshResult
  def initialize(text) = @text = text
  def plus = @text + "a"
end
class BorrowedResult
  def initialize(text) = @text = text
  def get = @text
  alias plus get
end
source = +"s"
receivers = [FreshResult.new(+"s"), BorrowedResult.new(source)]
value = receivers[1].plus
value << "!"
p value, source
