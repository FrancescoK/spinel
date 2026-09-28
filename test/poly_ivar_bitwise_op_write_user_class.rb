# `@x |= v` (and &=, <<=) on a poly ivar beside one user class defining the
# operator calls that class's operator only when the slot holds one; an
# Integer in the slot takes the numeric operator (#5469).
class Opts
  def initialize(options); @options = options; end
  def set(bit); @options |= bit; self; end
  def mask(b); @options &= b; self; end
  def sh(n); @options <<= n; self; end
  def to_i; @options; end
end
class Pair
  def initialize(items); @items = items; end
  def |(other); Pair.new(@items + other.items); end
  def &(other); Pair.new(@items & other.items); end
  def <<(n); Pair.new(@items + [n]); end
  def items; @items; end
end
p Opts.new(ARGV.empty? ? 1 : "x").set(256).to_i
p Opts.new(ARGV.empty? ? 7 : "x").mask(3).to_i
p Opts.new(ARGV.empty? ? 1 : "x").sh(4).to_i
p Opts.new(Pair.new([1])).set(Pair.new([2])).to_i.items
p Opts.new(Pair.new([1, 2])).mask(Pair.new([2])).to_i.items
