# A reader dispatched over the classes that hold a shared String, its value
# stored into a boxed Hash beside a call receiver: the store takes the
# reader's handle (the operand is bound as that handle), so it compiles and
# the Hash holds the very String (#9758)
class Widget
  attr_reader :location

  def initialize
    @location = nil
  end

  def redirect(path)
    @location = +""
    @location << path
  end
end

class Gadget
  attr_reader :location

  def initialize
    @location = nil
  end

  def redirect(path)
    @location = +""
    @location << path
  end
end

module Registry
  def self.[]=(key, value)
    store[key] = value
  end

  def self.store
    @store ||= {}
  end
end

class Reply
  attr_reader :headers

  def initialize
    @headers = {}
  end
end

buf = +"x"
Registry["k"] = buf
Registry["n"] = 1
buf << "y"

res = Reply.new
w = ARGV.empty? ? Widget.new : Gadget.new
w.redirect("/widgets/1")
res.headers["Location"] = w.location
w.location << "!"
p res.headers, res.headers["Location"].equal?(w.location)
