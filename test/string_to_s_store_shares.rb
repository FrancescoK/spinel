# A String's own conversion stored into a container is the String itself:
# a mutation through the element reaches the variable passed in.
def store_hash(value)
  h = {}
  h["k"] = value.to_s
  h["k"] << "!"
  h
end
s = +"abc"
p store_hash(s), s

def store_array(value)
  a = []
  a << value.to_str
  a[0] << "?"
  a
end
t = +"xyz"
p store_array(t), t

# WEBrick's HTTPResponse#[]= shape: an element mutation through another
# class's `[]` (a boxed receiver resolved by name) demands the setter's
# stores, and a mutation through this one reaches the String stored.
class Response
  def initialize
    @header = {}
  end

  def [](field)
    @header[field.downcase]
  end

  def []=(field, value)
    @chunked = value.to_s.downcase == "chunked" if field.downcase == "transfer-encoding"
    @header[field.downcase] = value.to_s
  end
end

class SplitHeader < Array
end

res = Response.new
type = +"text/html"
res["Content-Type"] = type
res["Content-Length"] = 13.to_s
res["content-type"] << "; charset=utf-8"
header = Hash.new([].freeze)
header["a"] = SplitHeader.new
header["a"] << +"x"
header["a"][-1] << " " << "y"
p res["content-type"], type, res["content-length"], header
