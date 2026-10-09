s = +"abc"
t = s
class Bag; include Enumerable; def initialize(x) = (@x = x); def each = yield(@x); end; Bag.new(s).each_entry { |x| x << "!" }
p s
p t
