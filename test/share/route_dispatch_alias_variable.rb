# A dispatch alias can return a borrowed String from a differently named
# method: the local takes the boxed dispatch's handle, the borrowed String
# itself (strbuf_poly_user_base), so the append shows through `source`.
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
