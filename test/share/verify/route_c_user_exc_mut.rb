s = +"abc"
t = s
class E < StandardError; def initialize(m) = (@m = m; super(m)); attr_reader :m; end; begin; raise E.new(s); rescue E => e; e.m << "!"; end
p s
p t
