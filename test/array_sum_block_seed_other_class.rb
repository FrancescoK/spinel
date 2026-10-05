# Array#sum(seed) { ... } with a seed of another class than the block's
# values that is not a number (a Hash, an Array, a Symbol, nil). CRuby's
# accumulator is the seed, so the first `+` raises for it. The typed
# accumulator took the seed as an sp_int and the generated C did not build;
# the fold is boxed now, as the blockless sum already decides by
# fold_seed_typed. A numeric or String seed keeps the typed accumulator.

def t(k)
  a = [1, 2, 3]
  h = {7 => 8}
  p(begin; a.sum(h) { |x| x }; rescue NoMethodError => e; e.message; end)
  p(begin; a.sum([0]) { |x| x * 2 }; rescue TypeError => e; e.message; end)
  p(begin; a.sum(:s) { |x| x }; rescue NoMethodError => e; e.message; end)
  p(begin; a.sum(nil) { |x| x }; rescue NoMethodError => e; e.message; end)
  p a.sum(10) { |x| x * 2 }
  p a.sum(0.5) { |x| x }
  p ["a", "b"].sum(+"") { |x| x }
end
t(ARGV.size)
