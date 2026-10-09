# Direct ivar annotations and container-return-induced pins must agree in
# either declaration order, as must differently named readers of one ivar.
class IvarFirst
  def initialize
    @items = [1] #: Array[String]
  end

  #: -> Array[Integer]
  def items = @items
end

class ReaderFirst
  #: -> Array[String]
  def items = @items

  def initialize
    @items = [1] #: Array[Integer]
  end
end

class StringsFirst
  def initialize
    @items = [1]
  end

  #: -> Array[String]
  def strings = @items

  #: -> Array[Integer]
  def items = @items
end

class IntegersFirst
  def initialize
    @items = [1]
  end

  #: -> Array[Integer]
  def items = @items

  #: -> Array[String]
  def strings = @items
end
