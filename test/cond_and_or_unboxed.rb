# `a && b` and `a || b` as a condition test each operand's truthiness in its
# own representation, without boxing the value when the operands' kinds
# differ: an object and a boolean, a nullable Integer and a String, nil and
# an Array. The right operand runs exactly when Ruby runs it, its own
# prelude included, and the answer is the same in if, unless, while,
# until, a ternary, a modifier and nested chains.

class Counter
  attr_reader :count, :name
  def initialize(n) = (@count = n; @name = "c#{n}")
  def child = Counter.new(@count + 1)
end

class Host
  def initialize(c) = @c = c
  def active? = (@c && @c.count == 0) ? :yes : :no
  def run
    n = 0
    10.times { n += 1 if @c && @c.count == 0 }
    n
  end
  def deep = (@c && @c.child.child.name == "c2") ? 1 : 0
end

$calls = []
def t(tag, v) = ($calls << tag; v)
def maybe_int(k) = k == 0 ? nil : k
def maybe_str(k) = k == 0 ? nil : "s#{k}"
def maybe_arr(k) = k == 0 ? nil : [k]

p Host.new(Counter.new(0)).active?, Host.new(nil).active?, Host.new(Counter.new(3)).active?
p Host.new(Counter.new(0)).run, Host.new(nil).run
p Host.new(Counter.new(0)).deep, Host.new(nil).deep

[0, 1, 2].each do |k|
  r = []
  r << (maybe_int(k) && maybe_str(k) ? :a : :b)
  r << (maybe_str(k) || maybe_arr(k) ? :c : :d)
  r << (t(:l, maybe_int(k)) && t(:r, k > 1) ? :e : :f)
  r << (t(:l2, maybe_arr(k)) || t(:r2, maybe_int(k)) ? :g : :h)
  r << (nil && maybe_int(k) ? :i : :j)
  r << (maybe_int(k) && (maybe_str(k) || :sym) && k.odd? ? :k : :l)
  r << :m unless maybe_str(k) && maybe_int(k)
  r << :n if !(maybe_arr(k) && maybe_int(k) == 2)
  p r
end
p $calls

i = 0
x = maybe_int(1)
i += 1 while x && i < 3 && t(:go, "go")
p i
j = 0
j += 1 until (j > 4 && :done) || nil
p j
f = 1.5
f = nil if ARGV.size > 3
p(f && t(:fl, "float") ? 1 : 2)
s = :sym
p((s && f) ? :both : :not, (s || f) ? :one : :none)

# a Float or String Range is always truthy, alone or as an operand
fr = 1.0..2.0
sr = "a".."b"
rlog = []
p(fr && i > 0 ? :fr : :no)
p(i > 5 || sr ? :sr : :no)
p(fr ? :alone : :no)
p(1) if (rlog << :l; fr) && (rlog << :r; sr)
p rlog
