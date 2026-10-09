# Direct ivar annotations and container-return-induced pins must agree in
# either declaration order, as must differently named readers of one ivar.
class IvarFirst
  # @rbs @items: Array[String]

  def initialize
    @items = [1]
  end

  #: () -> Array[Integer]
  def items = @items
end

class ReaderFirst
  #: () -> Array[String]
  def items = @items

  # @rbs @items: Array[Integer]

  def initialize
    @items = [1]
  end
end

class StringsFirst
  def initialize
    @items = [1]
  end

  #: () -> Array[String]
  def strings = @items

  #: () -> Array[Integer]
  def items = @items
end

class IntegersFirst
  def initialize
    @items = [1]
  end

  #: () -> Array[Integer]
  def items = @items

  #: () -> Array[String]
  def strings = @items
end
