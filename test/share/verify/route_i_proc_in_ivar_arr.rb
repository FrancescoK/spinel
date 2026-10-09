class K
  def initialize = (@hooks = [])
  def on(&b) = (@hooks << b)
  def fire(x) = @hooks.each { |h| h.call(x) }
end
kept = nil
k = K.new
k.on { |x| kept = x }
s = +"abc"
k.fire(s)
s << "!"
p kept
