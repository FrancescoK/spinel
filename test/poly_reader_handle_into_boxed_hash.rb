# A boxed receiver's reader whose arms box their shared fields
# (`w.location`, w a Widget or a Gadget) stored into a boxed Hash: the
# store reads it as its handle, but the operand order bound it ahead of
# the call as its bytes, so the store passed a `const char *` to
# sp_poly_as_strbuf and the C did not build (#9758). It is bound as its
# box, and the Hash keeps the String itself.
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
p res.headers
w.location << "?"
p res.headers["Location"], res.headers["Location"].equal?(w.location)
