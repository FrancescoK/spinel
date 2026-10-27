# An empty `{}` handed on through a parameter no call site types reaches a
# parameter another caller typed as one Hash kind: it is built as that kind.
class Response
  attr_accessor :body
  def initialize; @body = ""; end
end
class Request
  def initialize(h); @h = h; end
  def header(n); @h[n]; end
end
class Context
  attr_reader :request, :response
  def initialize(h); @request = Request.new(h); @response = Response.new; end
end
class Client
  attr_reader :request, :response
  def initialize(h); @request = Request.new(h); @response = Response.new; end
end
def run(c) = c.response.body = c.request.header("X").to_s
p run(Context.new({"X" => "tok"}))
p run(Client.new({}))

# two levels of forwarding
class Inner
  def initialize(h); @h = h; end
  def get(k); @h[k]; end
end
class Mid
  attr_reader :inner
  def initialize(h); @inner = Inner.new(h); end
end
class Top
  attr_reader :mid
  def initialize(h); @mid = Mid.new(h); end
end
p Inner.new({:a => 1}).get(:a)
p Top.new({}).mid.inner.get(:a)

# a plain method handing its parameter on
class Table
  def initialize(h); @h = h; end
  def at(k); @h[k]; end
end
def table(h) = Table.new(h)
p Table.new({1 => "one"}).at(1)
p table({}).at(1)

# the callee fills the Hash the caller passed
class Store
  def initialize(h); @h = h; end
  def put(k, v); @h[k] = v; end
end
class Holder
  attr_reader :store
  def initialize(h); @store = Store.new(h); end
end
Store.new({"a" => "b"})
h = {}
Holder.new(h).store.put("k", "v")
p h

# a copy of the parameter handed on
class Copy
  attr_reader :request
  def initialize(h); g = h; @request = Request.new(g); end
end
p Copy.new({}).request.header("X")

# Array, the same shape
class Lines
  def initialize(a); @a = a; end
  def first; @a[0]; end
end
class Doc
  attr_reader :lines
  def initialize(a); @lines = Lines.new(a); end
end
class Blank
  attr_reader :lines
  def initialize(a); @lines = Lines.new(a); end
end
class Wrap
  attr_reader :blank
  def initialize(a); @blank = Blank.new(a); end
end
p Doc.new(["one"]).lines.first
p Blank.new([]).lines.first
p Wrap.new([]).blank.lines.first
