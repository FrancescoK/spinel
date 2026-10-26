# spinel: share
# An attribute write whose receiver is reached through a boxed value (a
# block parameter that is one of two classes), of a `to_s` value, as a
# stored block's last expression: the receiver runs first and the value
# into a temp, which the String slot takes as its handle. With a class of
# the program's own defining `to_s`, the slot was handed the temp's bytes
# and the C did not compile; without one, the conversion's receiver was
# emitted a second time and its call ran twice.

$calls = 0

class Response
  attr_accessor :body
  def initialize; @body = ""; end
  def append(s); @body << s; end
end

class Request
  def initialize(h); @h = h; end
  def header(n); $calls += 1; @h[n]; end
end

class OtherRequest
  def initialize(h); @h = h; end
  def header(n); $calls += 1; @h.fetch(n, 7); end
end

class Context
  attr_reader :request, :response
  def initialize(h); @request = Request.new(h); @response = Response.new; end
end

class Client
  attr_reader :request, :response
  def initialize(h); @request = OtherRequest.new(h); @response = Response.new; end
end

class Safe
  def initialize(s); @s = s; end
  def to_s; @s; end
end

class Router
  def initialize; @routes = []; end
  def get(&blk); @routes << blk; end
  def call(i, c)
    r = @routes[i].call(c)
    p r
    c.response.body
  end
end

router = Router.new
router.get { |c| c.response.body = c.request.header("X").to_s }
router.get { |c| c.response.body = "plain" }
puts router.call(0, Context.new({ "X" => "tok" }))
puts router.call(0, Context.new({ "X" => Safe.new("safe") }))
puts router.call(0, Context.new({}))
puts router.call(0, Client.new({ "Y" => "z" }))
puts router.call(1, Client.new({}))
puts $calls

# the body is the String the header answered, one object
tok = +"shared"
ctx = Context.new({ "X" => tok })
router.call(0, ctx)
puts ctx.response.body.equal?(tok)
ctx.response.append("!")
puts tok
