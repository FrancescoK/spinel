# spinel: gc-stress
# The value of each, its kin and step with a block over a String Range is
# the Range itself, read again after the walk. A Range with an end made on
# the spot keeps both ends across it, whatever the block collects.

def churn(s)
  GC.start
  [s + "!", s + "?", s + "."].size
end

lo = "1"
z = ("10"..(lo + "5")).each { |s| churn(s) }
puts z.first, z.last
w = ((lo + "0").."15").step(2) { |s| churn(s) }
puts w.first, w.last
v = ("10"..(lo + "5")).step(2) { |s| s + "!" }
puts v.first, v.last
def walked(a) = ("20"..(a + "5")).each_with_index { |s, i| churn(s) }
r = walked("2")
p r.first, r.last, r.cover?("23")
p ("10"..(lo + "5")).reverse_each { |s| churn(s) }.last
p ("10"..(lo + "5")).each_entry { |s| churn(s) }.last
q = ("10"..(lo + "5")).each_slice(2) { |a| churn(a[0]) }
p q.first, q.last
q = ("10"..(lo + "5")).each_cons(2) { |a| churn(a[0]) }
p q.first, q.last
n = 0
20.times do |i|
  k = (i + 1).to_s
  e = ("10"..(k + "5")).each { |s| s + "!" }
  n += 1 if e.first == "10" && e.last == k + "5"
end
p n
