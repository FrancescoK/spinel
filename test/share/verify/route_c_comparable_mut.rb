s = +"abc"
t = s
class V; include Comparable; attr_reader :x; def initialize(x) = (@x = x); def <=>(o) = (@x << "!"; 0); end; V.new(s) == V.new(+"q")
p s
p t
