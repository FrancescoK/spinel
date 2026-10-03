# n.times / lo.upto(hi) / hi.downto(lo) without a block on a boxed receiver
# that is nil: nil has no such method, so CRuby raises NoMethodError. The
# receiver was read with the argument conversion, which raised TypeError.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue NoMethodError, TypeError => e
  puts "#{s}: #{e.class}"
end

src = [3, nil, "s"]
x = src[1]
n = src[0]
t("nil.times") { x.times.to_a }
t("nil.upto") { x.upto(2).to_a }
t("nil.downto") { x.downto(0).to_a }
t("n.times") { n.times.to_a }
t("n.upto") { n.upto(5).to_a }
t("n.downto") { n.downto(1).to_a }
