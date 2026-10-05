# An argument of no kind the method converts, to merge!/update (a Hash) or
# to concat/union/difference/intersection (an Array): CRuby evaluates the
# receiver and every argument in order, then raises the TypeError of the
# first argument that does not convert. On a receiver the inference boxed,
# the one-owner face re-entry's typed emitter declined such an argument and
# the call fell to NoMethodError; a typed Hash receiver did the same; a typed
# Array receiver named a later nil over an earlier boxed Hash, and ran an
# argument built in place ahead of the arguments before it. A Hash merges
# each argument before it converts the next.

def boxed(k)
  log = []
  [-> { [{1 => 2}, :x][k].update(nil) },
   -> { [{1 => 2}, :x][k].merge!({3 => 4}, Rational(1, 2)) },
   -> { h = k == 0 ? {1 => 2} : nil; h.update(nil) },
   -> { h = k == 0 ? {1 => 2} : nil; h.merge!(1.5) },
   -> { (log << :r; [{1 => 2}, :x][k]).update((log << :a0; :s), (log << :a1; {5 => 6})) },
   -> { [nil, {1 => 2}][k].update(nil) },
   -> { [:x, {1 => 2}][k].merge!(nil) },
   -> { [{1 => 2}, :x][k].update({3 => 4}) },
   -> { [+"ab", :x][k].concat(nil) },
   -> { [[1, 2], :x][k].concat([3], nil) },
   -> { (log << :r2; [[1], :x][k]).concat((log << :a2; :s), (log << :a3; [5])) }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  p log
end

def typed(k)
  log = []
  [-> { [1, 2].union(nil, [:s, [1]][k]) },
   -> { [1, 2].union([1], 7) },
   -> { [[1, 2], [3]].difference([{1 => 2}, [1]][k], [1], nil) },
   -> { [1].concat([{1 => 2}, [1]][k], [2], nil) },
   -> { (log << :r; [1, 2]).union((log << :a0; nil), (log << :a1; [3])) },
   -> { {1 => 2}.update(nil) },
   -> { {"a" => 1}.update({"b" => 2}, 7) },
   -> { {"a" => 1}.merge!(1.5) },
   -> { {"a" => 1}.freeze.merge!(nil) },
   -> { h = {1 => 2}; begin; h.update({3 => 4}, 7); rescue TypeError => e; [e.message, h]; end },
   -> { (log << :r2; {"a" => 1}).update((log << :a2; [{1 => 2}, :x][1 - k]), (log << :a3; nil)) }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  p log
end

boxed(ARGV.size)
typed(ARGV.size)
