# Hash#fetch handed a block as `&b`: the caller's literal once the method is
# spliced into its site, a proc's value at run time, and KeyError when the
# caller gave none. The block was read as an empty one and every miss
# answered nil.
def f(h, k, &b) = h.fetch(k, &b)
h = {"a" => 1}
p f(h, "zz") { |k| k * 2 }
p f(h, "a") { |k| k * 2 }
pr = proc { |k| k * 3 }
p f(h, "zz", &pr)
begin
  f(h, "nope")
rescue KeyError => e
  p e.message
end
x = [{"q" => 1}, 2].first
p x.fetch("q", &pr), x.fetch("w", &pr)
