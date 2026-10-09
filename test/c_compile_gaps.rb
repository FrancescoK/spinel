$log = []
def eff(v) = ($log << v; v)
def t
  yield
rescue => e
  [e.class, e.message]
end

h = {a: 1}
p t { h.merge(raise("lone")) }
p t { h.merge({b: 2}, raise(ArgumentError, "second")) }
p t { h.merge!(raise(ArgumentError, "bang")) }
p t { x = h.merge(raise("as value")); x }
p t { true ? h.merge(raise("arm")) : h }
p t { eff([1]).push(eff(2), raise("order")) }
p $log
p(catch(:t) { [1].push(throw(:t, 9)) })
p(catch(:u) { h.merge(throw(:u, 7)) })
p t { [1].push(raise("push")) }
p t { "s" + raise("plus") }
p t { (puts 1; raise("seq")) }
p h

class Raiser
  def raise(m) = "own #{m}"
  def go(h) = h.merge({b: raise("x")})
end
p Raiser.new.go({a: 1})
a = nil
p a&.push(raise("never"))

p t { "12".between?("1", 99) }
p t { "12".between?(99, "z") }
p t { "12".between?(nil, "z") }
p t { "12".between?("1", :z) }
p t { "12".between?("1", 2.5) }
p t { "12".between?("1", [1]) }
p t { "12".between?("1", {}) }
p t { "12".between?("1", "9") }
p t { "12".clamp("1", 99) }
p t { "12".clamp(1, 99) }
p t { "12".clamp(99, 1) }
p t { "12".clamp(nil, "z") }
p t { "12".clamp(nil, 99) }
p t { "12".clamp(1, nil) }
p t { "12".clamp("1", "9") }
x = 99
p t { "12".between?("1", x) }
p t { "12".clamp("1", x) }

[[:to_i, :size], [:chomp, :size], [:include?, :size]].each do |names|
  n = names[0]
  p t { "12\n".send(n, "1", 99) }
end
