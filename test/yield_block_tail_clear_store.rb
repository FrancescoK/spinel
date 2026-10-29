# A yielded block whose last statement empties or stores into a container
# answers what the call answers: clear the receiver, store and []= the
# value. The yield's value here is general, as other blocks answer other
# kinds.

def t = yield

x = [1, "a"]
y = t { x.clear }
p y, x, y.equal?(x)
y << 3
p x

def u
  yield
end
z = [:s, 2.5]
p(u { z.clear })

@a = [1, :s]
p t { @a.clear }.size

begin
  t { [1, "a"].freeze.clear }
rescue FrozenError => e
  p e.class
end

w = [1, "b"]
p t { w.clear; 5 }

n = ARGV.size > 5 ? [1, "a"] : nil
p(t { n&.clear })

hh = {"a" => 1}
k = "k"
p(t { hh.store(k, 4) })
p(t { hh["m"] = 5 })
p(t { "s" })
p hh

ia = [1, 2]
p(t { ia[0] = 3 })
p(t { :sym })
p ia
