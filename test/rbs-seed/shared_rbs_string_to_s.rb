# Under --share-strings (#6765), a method an --rbs signature declares
# `(untyped) -> String` whose value is `message.to_s` over its boxed
# parameter answers the String the box holds, also where a class of the
# program defines its own to_s answering a new String (`def to_s = "ev"`).
# The to_s dispatch answers each arm as a handle, the box's own where the
# box holds a String, and the method publishes it; before, such a user to_s
# was read before its own answer was decided, the tail answered the box's
# bytes, and every flow of the answer the rule shares was refused.
class ShrtsTagger
  def initialize
    @tags = []
  end

  def tagged(message)
    return message.to_s if @tags.empty?
    "[x] " + message.to_s
  end

  def tag(message)
    return "" if message.nil?
    message.to_s
  end
end

class ShrtsEv
  def to_s
    "ev"
  end
end

def shrts_sink(s)
  s
end

buf = +"boot"
buf << "ed"
t = ShrtsTagger.new
puts shrts_sink(t.tagged(buf))
puts shrts_sink(t.tagged("up"))
x = +"x"
h = { t.tag(x) => 1 }
y = t.tag(x)
y << "!"
p x, h, t.tag(nil), t.tag(ShrtsEv.new), t.tag(:sym), t.tag(42)
p ShrtsEv.new.to_s
