s = +"abc"
t = s
class K; def mut(x) = x << "!"; end; [K.new, 1].first.send(:MUT.downcase, s)
p s
p t
