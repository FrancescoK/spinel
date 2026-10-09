s = +"abc"
t = s
class K; def initialize(x) = (@x = x); def go = @x << "!"; end; K.new(s).go
p s
p t
