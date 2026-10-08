# The inherited Object method can return a String already held by another name.
class FreshResult
  def initialize(text) = @text = text
  def instance_exec = @text + "a"
end
class BorrowedResult; end
source = +"s"
receivers = [FreshResult.new(+"s"), BorrowedResult.new]
values = [receivers[0].instance_exec, receivers[1].instance_exec { source }]
values[1] << "!"
p values, source
