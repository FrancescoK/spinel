# `h.fetch(key, default, &blk)` where blk is a method's own block, nil when
# the caller passed none: a nil block is no block, so a missing key answers
# the default. The block-argument form ignored the default and raised
# KeyError (Thor's HashWithIndifferentAccess#fetch, `options.fetch(:x, "y")`).
class Options
  def initialize(hash) = @hash = hash

  def fetch(key, *args, &block)
    @hash.fetch(key.to_s, *args, &block)
  end
end

def lookup(h, k, d, &b) = h.fetch(k, d, &b)

h = { "a" => "1" }
p lookup(h, "a", "none")
p lookup(h, "b", "none")
p lookup(h, "b", "none") { |k| "block #{k}" }

o = Options.new(h)
p o.fetch(:a)
p o.fetch(:b, "none")
p o.fetch(:b) { |k| "block #{k}" }
begin
  o.fetch(:b)
rescue KeyError => e
  puts e.message
end
