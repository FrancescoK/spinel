# A boxed receiver's reader (`@r.host`, @r of no known class) asked for its
# arms before the receiver's candidates were typed answered none, and the
# plan kept that answer: the method returning it then carried no handle,
# and a local written from it, a String another name changes in place
# through a call the compiler cannot follow, was refused. The plan is
# asked again once the tables change.
class Req
  attr_reader :host
  def initialize(h) = @host = h
end

class Ctl
  def initialize(r, out) = (@r = r; @out = out)
  def host_of = @r.host.to_s
  def bare_host = @r.host

  def go
    h = host_of
    h.empty? ? "" : h.downcase
  end

  def go_bare
    h = bare_host
    h + "!"
  end

  def put(io) = io << "x"
  def out = @out
  def run = put(public_send(("o" + "ut").to_sym))
end

s = +"Example.COM"
buf = +""
c = Ctl.new([Req.new(s), 1][0], buf)
c.run
p c.go, c.go_bare, buf, s
