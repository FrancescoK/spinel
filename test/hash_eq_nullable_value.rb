# Hash#== across storage kinds reads an Integer slot's nil word as nil: a Hash
# built from a parameter called with nil and with an Integer is a Hash of
# nullable Integers, and equals the literal with a nil.
def f(v) = { "k" => v }
p f(nil) == { "k" => nil }
p f(0) == { "k" => 0 }
p f(nil) == { "k" => 0 }
p f(nil) == f(nil)
p f(nil) == f(0)
v = [nil, 0][ARGV.size]
p({ "k" => v } == { "k" => nil })
p({ "k" => v } == { "k" => 0 })
def g(s) = { "k" => s }
p g(nil) == { "k" => nil }
p g("x") == { "k" => "x" }
p g("x") == { "k" => nil }
h = { 1 => nil, 2 => 3 }
h2 = { 1 => nil, 2 => 3 }
p h == h2
def ig(v) = { 1 => v }
p ig(nil) == { 1 => nil }
p ig(5) == { 1 => nil }
