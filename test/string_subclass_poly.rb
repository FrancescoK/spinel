# A String subclass made by Class.new with a block, one beside a reopen of
# String, and instances boxed in a mixed Array or a local that held a String.
class String
  def shout = upcase + "!"
end
Label = Class.new(String) do
  def tag = "[#{self}]"
end
class Name < String
  def initialize(first, last)
    super("#{first} #{last}")
    @first = first
  end
  attr_reader :first
end
l = Label.new("ok")
p l, l.tag, l.shout, l.class
n = Name.new("Ada", "Lovelace")
p n, n.first, n.shout, n.length, n.start_with?("Ada")
xs = [Name.new("a", "b"), "plain", Label.new("l")]
xs.each { |x| p [x, x.class, x.size] }
p xs.map(&:upcase), xs.sort, xs.join("|")
def pq(str)
  query = Hash.new
  str.split(/&/).each { |x|
    key, val = x.split(/=/, 2)
    val = val.to_s
    val = Name2.new(val)
    val.name = key
    query[key] = val
  }
  query
end
class Name2 < String
  attr_accessor :name
end
q = pq("a=1&b=2")
p q.keys, q.values, q["a"].name, q["b"].class
