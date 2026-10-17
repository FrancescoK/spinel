# A boxed `[]=` one of whose targets appends to the value in place lifts a
# poly local's String to its handle first (#6179), so that target appends
# to the caller's own String. Where the receiver is a Hash typed with
# String values, the handle stored there is its String: it was refused as
# a store of another kind (TypeError), outside --share-strings.
class Bag
  def initialize
    @log = []
  end

  def []=(k, v)
    v << "!"
    @log << v
  end

  def log = @log
end

class Req
  attr_accessor :hdrs

  def initialize(x)
    @hdrs = x
  end
end

def store(r, key, value)
  r.hdrs[key] = value
end

by_name = { "a" => "b" }
by_index = { 1 => "one" }
v = [+"x", 1][0]
store(Req.new(by_name), "Host", v)
store(Req.new(by_index), 2, v)
y = +"y"
bag = Req.new(Bag.new)
store(bag, "k", y)
p by_name
p by_index
p bag.hdrs.log
p y
