# A default argument that names the callee's own parameter (`width =
# obj.length`), at a call inside a proc body that captured a caller's local
# of the same name, reads the argument: it read the capture, which answered
# the wrong width for a captured String and did not build for a captured
# Hash (#9263, PrettyPrint#text under pp's seplist)
class Out
  def initialize = @parts = []
  def text(obj, width = obj.length)
    @parts << "#{obj}:#{width}"
  end
  attr_reader :parts
  def group(&block)
    @last = block
    block.call
  end
  def label(obj)
    group { text "ab"; text obj; nil }
  end
  def show(obj)
    group {
      obj.each_key { |v|
        text v.to_s
        text obj[v].inspect
      }
      nil
    }
  end
end
o = Out.new
o.label("hello")
o.show({ a: 1, bb: "x" })
o.show({ "k" => [1, 2] })
p o.parts
