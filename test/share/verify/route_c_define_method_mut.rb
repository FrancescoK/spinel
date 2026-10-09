s = +"abc"
t = s
class K; define_method(:mut) { |x| x << "!" }; end; K.new.mut(s)
p s
p t
