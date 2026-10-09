class Bag; include Enumerable; def initialize(x) = (@x = x); def each = yield(@x); end
s = +"abc"
r = Bag.new(s).map { |x| x }[0]
r << "!"
p s
p r
