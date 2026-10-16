# A `Hash[Symbol, Integer]` or `Hash[Symbol, String]` seed named a Hash kind
# the analyzer does not have (sym_int_hash, sym_str_hash), so the parser
# dropped it and the slot fell to poly: a box the analysis took for no Hash
# at all, and an ivar holding `{}` lost even its inferred kind. The
# extractor now maps every Symbol-keyed Hash to sym_poly_hash, the kind
# `Hash[Symbol, untyped]` has: the values are boxed, the Hash is a Hash.
# spinel: rbs-seed-check
class Tally
  def initialize
    @counts = {}
  end

  def bump(name)
    @counts[name] = (@counts[name] || 0) + 1
    @counts[name]
  end

  def names
    @counts.keys
  end

  def total(h)
    t = 0
    h.each_value { |v| t += v }
    t
  end

  def label(h)
    h.keys.size
  end
end

t = Tally.new
t.bump(:a)
t.bump(:a)
t.bump(:b)
p t.names
p t.total({ a: 2, b: 1 })
p t.label({ x: "y" })
