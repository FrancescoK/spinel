# A frozen Array's delete and delete_at raise FrozenError only when they
# would remove an element; a miss answers nil. clear always raises. This
# holds for every element kind, and for an Array read out of a mixed Array.
O = Object.new

def t(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue FrozenError => e
  msg = e.message.include?("#<") ? "" : ": #{e.message}"
  puts "#{label}: #{e.class}#{msg}"
end

ai = [1, 2].freeze
as = ["a", "b"].freeze
ay = [:a, :b].freeze
af = [1.5, 2.5].freeze
ap = [1, "a"].freeze
ao = [O, O].freeze
an = [1, nil].freeze
afn = [1.5, nil].freeze

t("int delete hit") { ai.delete(1) }
t("int delete miss") { ai.delete(9) }
t("int delete_at hit") { ai.delete_at(0) }
t("int delete_at miss") { ai.delete_at(9) }
t("str delete hit") { as.delete("a") }
t("str delete miss") { as.delete("z") }
t("str delete_at hit") { as.delete_at(-1) }
t("str delete_at miss") { as.delete_at(-9) }
t("sym delete hit") { ay.delete(:a) }
t("sym delete miss") { ay.delete(:z) }
t("sym delete_at hit") { ay.delete_at(0) }
t("sym delete_at miss") { ay.delete_at(9) }
t("float delete hit") { af.delete(1.5) }
t("float delete miss") { af.delete(9.5) }
t("float delete_at hit") { af.delete_at(1) }
t("float delete_at miss") { af.delete_at(2) }
t("mixed delete hit") { ap.delete(1) }
t("mixed delete miss") { ap.delete(9) }
t("mixed delete_at hit") { ap.delete_at(0) }
t("mixed delete_at miss") { ap.delete_at(9) }
t("object delete hit") { ao.delete(O).equal?(O) }
t("object delete miss") { ao.delete(3) }
t("object delete_at hit") { ao.delete_at(0).equal?(O) }
t("object delete_at miss") { ao.delete_at(9) }
t("int nil delete hit") { an.delete(nil) }
t("int nil delete miss") { an.delete(7) }
t("float nil delete hit") { afn.delete(nil) }
p [ai, as, ay, af, ap, an, afn]
p ao.size

# an Array read out of a mixed Array is a boxed value
b = [[1, 2].freeze, ["x"].freeze, [1, "a"].freeze, nil]
t("boxed int clear") { b[0].clear }
t("boxed str clear") { b[1].clear }
t("boxed mixed clear") { b[2].clear }
t("boxed mixed delete hit") { b[2].delete(1) }
t("boxed mixed delete miss") { b[2].delete(9) }
t("boxed int delete miss") { b[0].delete(9) }
t("boxed str delete_at miss") { b[1].delete_at(4) }
t("boxed mixed delete_at hit") { b[2].delete_at(0) }
p b

# not frozen: the same calls still change the Array
c = [[1, 2], ["x"], [1, "a"], nil]
c[0].clear
c[2].delete(1)
c[1].delete_at(0)
p c
