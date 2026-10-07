# A literal in an uncalled method cannot expose a copy of its Strings.
# The stored block leaves the live receiver poly, whose unknown sharing
# reaches the dead caller too. Cover each typed String container and keep
# the called methods' returned Strings shared with their caller.
def consume(values)
  values.each { |value| p value.class }
end
class Pool
  def insert(values) = consume(values)
end
class NeverCalled
  def unused_array
    @items.each { |item| @pool.insert([item.text]) }
  end
  def unused_string_hash
    @items.each { |item| @pool.insert({"key" => item.text}) }
  end
  def unused_integer_hash
    @items.each { |item| @pool.insert({1 => item.text}) }
  end
  def called_array(s) = [s]
  def called_hash(s) = {"key" => s}
end
class Item
  def text = "frozen"
end
class Yielding
  def each
    yield 1
  end
end
class Endpoint
  def initialize(handler) = @handler = handler
  def call(db) = @handler.call(db)
end
def endpoint(&handler) = Endpoint.new(handler)
endpoint { |db| db.insert([1, nil]) }.call(Pool.new)
s = +"a"
obj = NeverCalled.new
obj.called_array(s)[0] << "b"
obj.called_hash(s)["key"] << "c"
p s
