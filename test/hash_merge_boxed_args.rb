# merge! and update on a typed Hash given a Hash that the inference boxed
# (read out of a mixed Array) merge it, as CRuby does, where the call raised
# NoMethodError; a block resolves the conflicts. Several arguments are all
# evaluated before the first merge, and the Hashes ahead of an argument that
# is no Hash merge in before its TypeError, on a typed receiver and on a
# boxed one, which also checks frozen first.

def t(k)
  log = []
  r = {"a" => +"x"}
  [-> { r.merge!([:x, {"c" => +"z"}][k]) },
   -> { r.merge!([{"c" => +"z"}, :x][k]) },
   -> { {"a" => 1}.update([{"c" => 2}, :x][k]) },
   -> { {"a" => 1}.merge!({"b" => 2}, [{"c" => 3}, :x][k]) },
   -> { {"a" => 1}.merge!({"a" => 2}, [{"a" => 3}, :x][k]) { |key, o, n| o + n } },
   -> { h = {"a" => 1}; [h.merge!((log << :a0; {"b" => 2}), (log << :a1; {"c" => h.size})), log] },
   -> { h = {"a" => +"x"}; (log << :r; h).merge!((log << :b0; 1.5), (log << :b1; [1.5, {1 => 2}][k])) },
   -> { g = [{1 => 2}, :x][k]; begin; g.update({3 => 4}, 7); rescue TypeError => e; [e.message, g]; end },
   -> { [{1 => 2}.freeze, :x][k].update({3 => 4}, 7) },
   -> { h = {"a" => 1}; h.merge!([{"d" => 4}, :x][k], {"e" => 5}) { |key, o, n| n } }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  p log
end
t(ARGV.size)
