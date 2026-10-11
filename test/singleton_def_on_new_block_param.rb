# `def x.m` on the block parameter of `K.new { |x| }`, when K's initialize
# hands the block the new object: the singleton methods land on that object,
# as they do for `x = K.new; def x.m`.

class Box
  def initialize(v)
    @v = v
    yield self
  end

  def v = @v
end

Box.new(3) do |b|
  def b.double = v * 2
  def b.bump = @v + 1
  p b.double
  p b.bump
  p b.class
  p b.is_a?(Box)
end

# initialize calling its &block, and a block that also captures an outer
# local: the singleton def's own parameters are not reads of the block's.
class Parser
  def initialize(&block)
    @long = {"name" => 1}
    block.call(self) if block
  end

  def top = @long
end

def configure
  options = {}
  Parser.new do |opts|
    options[:seen] = true
    def opts.topdict(name) = (name.length > 1 ? top : nil)
    def opts.alias(from, to) = (dict = topdict(from); dict[to] = dict[from])
    opts.alias "name", "include"
    p opts.top
  end
  options
end
p configure

# a block parameter sharing an outer local's name
def shadowed
  opts = 1
  Box.new(5) do |opts|
    def opts.twice = v * 2
    p opts.twice
  end
  p opts
end
shadowed

# a singleton on a plain local whose method answers an Integer that can be nil
o = Parser.new
def o.copy(from, to) = (dict = top; dict[to] = dict[from])
p o.copy("name", "alias")
p o.copy("missing", "other")
p o.top
