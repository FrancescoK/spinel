class Hash
  def each_with_object(m) = (each { |k, v| yield([k, v], m) }; m)
end
class W
  def initialize(t) = @t = t
  def keep(kv, m) = (m << "#{@t}#{kv[0]}"; m)
end
class H
  def initialize = (@h = {a: 1, b: 2})
  def run = p(@h.each_with_object([], &W.new("w").method(:keep)))
end
H.new.run
