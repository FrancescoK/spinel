# Array-only methods on a receiver carried in a boxed slot: a Hash, a String
# or a Range lacks them and raises NoMethodError, as in CRuby, instead of
# answering its members.

def t(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue NoMethodError
  puts "#{label}: NoMethodError"
rescue ArgumentError => e
  puts "#{label}: ArgumentError #{e.message}"
end

def last_n(o, n) = o.last(n)
def last0(o) = o.last
def first0(o) = o.first
def first_n(o, n) = o.first(n)
def rot(o) = o.rotate
def rot_n(o, n) = o.rotate(n)
def samp(o) = o.sample.class
def samp_n(o, n) = o.sample(n).size
def vals(o) = o.values_at(0)
def flat(o) = o.flatten
def len(o) = o.length
def cnt(o) = o.count
def join(o) = o.join(",")
def at0(o) = o.at(0)

[[3, 1, 2], {a: 1, b: 2}, (1..3), "abc", 5].each do |o|
  puts "== #{o.class}"
  t("last(n)") { last_n(o, 1) }
  t("last") { last0(o) }
  t("first") { first0(o) }
  t("first(n)") { first_n(o, 1) }
  t("rotate") { rot(o) }
  t("rotate(n)") { rot_n(o, 1) }
  t("sample") { samp(o) }
  t("sample(n)") { samp_n(o, 1) }
  t("values_at") { vals(o) }
  t("flatten") { flat(o) }
  t("length") { len(o) }
  t("count") { cnt(o) }
  t("join") { join(o) }
  t("at") { at0(o) }
end

class Box
  def initialize(v) = @v = v
  def tail = @v.last(1)
end
p Box.new([1, 2]).tail
begin
  p Box.new({k: 1}).tail
rescue NoMethodError
  puts "ivar: NoMethodError"
end
