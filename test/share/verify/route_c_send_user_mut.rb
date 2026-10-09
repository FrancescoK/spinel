s = +"abc"
t = s
class K; def mut(x) = x << "!"; end; K.new.send(:mut, s)
p s
p t
