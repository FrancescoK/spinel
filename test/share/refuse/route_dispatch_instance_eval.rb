# The inherited Object method can return a String already held by another name.
class FreshResult
  def initialize(text) = @text = text
  def instance_eval = @text + "a"
end
class BorrowedResult
  def initialize(text) = @text = text
end
source = +"s"
receivers = [FreshResult.new(+"s"), BorrowedResult.new(source)]
values = [receivers[0].instance_eval, receivers[1].instance_eval { @text }]
values[1] << "!"
p values, source
