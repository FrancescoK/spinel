# `h[k] ||= v` (and `&&=`) into a Hash of typed values, where v is poly --
# here a method whose optional `val = nil` is passed somewhere, so its
# reader answers a boxed value. The store unboxes it to the Hash's value
# representation, as `h[k] = v` does.

class Config
  def initialize
    @term = 'xterm-256color'
    @n = 3
    @f = 1.5
  end

  def term(val = nil) = val ? @term = val : @term
  def n(val = nil) = val ? @n = val : @n
  def f(val = nil) = val ? @f = val : @f
end

c = Config.new
c.term(nil)
c.n(nil)
c.f(nil)

env = {"a" => "b"}
env['TERM'] ||= c.term
env['a'] ||= c.term
p env
env['a'] &&= c.term
p env

counts = {"x" => 1}
counts['y'] ||= c.n
counts['x'] &&= c.n
p counts

ws = {"x" => 0.5}
ws['y'] ||= c.f
p ws

# an Integer value that may be nil keeps the nil, as `h[k] = v` keeps it
def maybe(v = nil) = v
maybe(1)
h = {"x" => 1}
h['z'] ||= maybe
p h
h['z'] ||= maybe(5)
p h
