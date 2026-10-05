# A stored blockless select / reject (of a Hash or an Array) driven by
# `.with_index { }` answers the kept elements, as CRuby does: a Hash of the
# kept pairs for a Hash. A Hash's answered the whole Hash.
h = {"a" => 1, "b" => 2, "c" => 3}
e = h.select
p e.with_index { |kv, i| i.odd? }
p h.reject.with_index { |kv, i| i.zero? }
p h.send(:select).with_index { |kv, i| i.odd? }
a = [1, 2, 3, 4]
f = a.select
p f.with_index { |x, i| i.even? }
p a.reject.with_index(1) { |x, i| i == 2 }
