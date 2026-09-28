# `recv[key]` on a receiver of more than one class answers a Hash's default
# for a missing key, as CRuby does, where it answered nil: a String, Symbol or
# Integer key, beside a user class's own [] or not.
class Row
  def [](key) = "row:#{key}"
end

def lookup(recv, key) = recv[key]

h = Hash.new("")
h["a"] = "b"
p lookup(h, "a"), lookup(h, "missing"), lookup(Row.new, "x")
s = Hash.new("none")
s[:a] = "b"
p lookup(s, :a), lookup(s, :zz)
n = Hash.new(7)
n[3] = 1
p lookup(n, 3), lookup(n, 4)
t = Hash.new("dflt")
t[1] = "one"
p lookup(t, 1), lookup(t, 2)
# a hash with no default still answers nil
e = {"k" => 1}
p lookup(e, "k"), lookup(e, "nope")
f = {1 => 2}
p lookup(f, 1), lookup(f, 9)

def plain(recv, key) = recv[key]
p plain(n, 4), plain(t, 5), plain(f, 9)
