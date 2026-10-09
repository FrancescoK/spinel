# A container return annotation also pins the instance variable it reads.
# External getter and direct ivar declarations must agree with that pin,
# whether it came from an ivar annotation or another method's return.
class ExplicitReader
  # @rbs @items: Array[String]

  def initialize
    @items = ["explicit"]
  end

  def items = @items
end

class ImplicitReader
  def initialize
    @items = ["implicit"]
  end

  #: () -> Array[String]
  def strings = @items

  def items = @items
end

class MemoReader
  #: () -> Array[String]
  def self.strings
    @items ||= ["memo"]
  end

  def self.items = @items
end

p ExplicitReader.new.items
reader = ImplicitReader.new
p reader.strings, reader.items
p MemoReader.strings, MemoReader.items
