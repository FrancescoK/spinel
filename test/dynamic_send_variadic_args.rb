# `send(method, *args, **kwargs, &block)`: with a splat or a keyword splat
# among the arguments the count is a run-time matter. The arity filter that
# keeps a defined name out of the dispatch at an argument count none of its
# definitions take read the two as two positionals, so a one-parameter
# method had no arm and the send raised NoMethodError.
class Sink
  def initialize = @lines = []
  def bare(msg) = @lines << "bare #{msg}"
  def pair(a, b = 2) = @lines << "pair #{a} #{b}"
  def lines = @lines
end
class Relay
  def initialize(s) = @s = s
  def go(method, *args, **kwargs, &block) = @s.send(method, *args, **kwargs, &block)
  def go2(method, *args) = @s.send(method, *args)
end
s = Sink.new
r = Relay.new(s)
r.go(:bare, "x")
r.go(:pair, 1)
r.go2(:pair, 3, 4)
r.go2(:bare, "y")
p s.lines
