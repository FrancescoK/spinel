# The snapshot is hand-written: CRuby's Hash holds every key and value, so it cannot come from reference Ruby.
# A key or value whose kind is decided at run time, stored into a typed hash
# the compiler did not widen for it, is refused with TypeError rather than
# converted to the variant's kind: a String value into a Hash[String,
# Integer] was stored as 0. nil is the value kind's own nil.
def try(label)
  yield
rescue TypeError => e
  puts "#{label}: TypeError: #{e.message}"
end
def pick(i) = i > 0 ? 1 : "z"
def pick_key(i) = i > 0 ? "k" : :k
def put(h, v); h["q"] = v; end
x = {"a" => 1}
put(x, pick(1))
try("value") { put(x, pick(0)) }
p x
def put_nil(h, v); h["n"] = v; end
put_nil(x, 7)
put_nil(x, nil)
p x
def putk(h, k); h[k] = 5; end
y = {"a" => 1}
putk(y, pick_key(1))
try("key") { putk(y, pick_key(0)) }
p y
s = {"a" => "b"}
def puts_v(h, v) = (h["c"] = v)
try("expr value") { p puts_v(s, pick(0)) }
try("expr value int") { puts_v(s, pick(1)) }
p s
