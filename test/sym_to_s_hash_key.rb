# A Hash keyed by Symbol#to_s finds its entries again with the String's hash
# kept in its header (#10548), and a mutated copy of a to_s is a String of
# its own.
h = {"alpha" => 1, "beta" => 2, "abc" => 3}
syms = [:alpha, :beta, :gamma, :alpha, :abc]
p syms.map { |s| h[s.to_s] }
p syms.map { |s| h.key?(s.to_s) }
t = :abc.to_s.dup
p h[t]
t << "x"
p [t, h[t], h[:abc.to_s], :abc.to_s]
g = {}
syms.each { |s| g[s.to_s] = (g[s.to_s] || 0) + 1 }
p g
p "beta".hash == :beta.to_s.hash, :beta.to_s.eql?("beta")
