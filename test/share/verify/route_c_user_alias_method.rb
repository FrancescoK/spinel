s = +"abc"
t = s
class K; def mut(x) = x << "!"; alias_method :mut2, :mut; end; K.new.mut2(s)
p s
p t
