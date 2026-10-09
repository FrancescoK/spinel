class K; def initialize(x) = (@x = x); def fr = @x.freeze; end
s = +"a"; t = s; t << "b"; K.new(s).fr; p t.frozen?
