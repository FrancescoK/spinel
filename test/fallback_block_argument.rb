# A Proc or lambda handed as a block argument to fetch, delete or
# fetch_values (an Array's or a Hash's) runs for a missing key, and one
# handed to a Hash's merge! or update runs for each conflicting key, as a
# block literal does. They were ignored: the call answered nil, or kept nil
# for the conflict, and an Array's delete did not build.
pr = proc { |k| "no #{k}" }
lam = ->(k) { k.to_s * 2 }
h = { "a" => 1 }
p h.fetch("z", &pr), h.fetch("a", &pr), h.fetch("q", &lam)
p h.fetch_values("a", "zz", &pr)
p h.delete("z", &pr), h.delete("a", &pr), h
sy = { a: 1 }
p sy.fetch(:b, &pr), sy.delete(:c, &pr)
ih = { 1 => "x" }
p ih.fetch(2, &pr), ih.delete(3, &pr), ih.delete(1, &pr)
a = [1, 2]
p a.fetch(9, &pr), a.fetch(0, &pr), a.fetch(-5, &lam)
p a.delete(7, &pr), a.delete(1, &pr), a
p ENV.fetch("SPINEL_NO_SUCH_VAR_X", &pr)
m = { a: 1 }
m.update({ a: 2, b: 3 }, &->(k, x, y) { x * 10 + y })
p m
s = { "a" => 1 }
s.merge!({ "a" => 2 }, &proc { |k, x, y| "#{k}#{x}#{y}" })
p s
c = proc { |k, x, y| x + y }
n = { "a" => 1 }
n.merge!({ "a" => 2 }, { "a" => 3 }, &c)
p n
