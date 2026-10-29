# A reader named append or unshift (attr_reader, a Struct member) keeps
# the class's answer on a boxed receiver.
class AppendReader
  attr_reader :append
  def initialize = @append = 7
end
SReader = Struct.new(:unshift)
rs = [AppendReader.new, SReader.new(5)]
p rs[0].append
p rs[1].unshift
