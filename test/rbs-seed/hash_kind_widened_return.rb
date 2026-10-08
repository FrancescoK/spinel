# A narrower hash storage kind returned through a wider declared one.
#
# Ruby has one Hash; this runtime has seven storage kinds and they do not share
# a layout. `Hash[String, untyped]` is a perfectly accurate signature for a
# method returning {"k" => "v"}, but the body builds the string-VALUED kind, so
# returning the pointer through the poly-valued signature reinterprets it and
# every read comes back as garbage -- silently, on a compiler that only warns
# about the type mismatch. It converts now, entry by entry, as the array side
# already did.
# spinel: rbs-seed-run
class Facade
  def params
    { "charset" => "utf-8" }
  end

  def counts
    { "a" => 1, "b" => 2 }
  end

  def syms
    { a: 1, b: 2 }
  end

  # already the declared kind: nothing to convert
  def mixed
    { "n" => 1, "s" => "two" }
  end
end

f = Facade.new
p f.params["charset"]
p f.counts["a"]
p f.counts["b"]
p f.counts.size
p f.syms[:b]
p f.mixed["s"]
p f.mixed["n"]

# the converted hash behaves as a Hash, not just at one key
acc = []
f.counts.each { |k, v| acc << "#{k}=#{v}" }
p acc
p f.params.keys
