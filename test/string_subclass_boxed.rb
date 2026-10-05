# String subclass instances held in boxed values (#7449): a box is the
# String's handle, so length, join, ==, hash and to_s take it as a String,
# while class, is_a?, instance_of?, ===, case/when, the subclass's own
# methods (and super into a parent's) and the unbox into a slot of the
# class read its class off the instance. An append through a boxed alias
# changes the one instance.

class Tag < String
  def initialize(s, kind = :inline)
    super(s)
    @kind = kind
  end
  attr_reader :kind
  def describe = "#{kind} #{self}"
end
class Strong < Tag
  def describe = "strong " + super
end
class Other
  def describe = "other"
end

vals = [Tag.new("em"), Strong.new("b", :block), "plain", 7, Other.new]
vals.each do |v|
  kind = case v
         when Strong then "Strong"
         when Tag then "Tag"
         when String then "String"
         else "other"
         end
  p [v.class, kind, v.is_a?(String), v.instance_of?(String), v.is_a?(Tag), String === v]
end
p vals.first(3).map(&:length)
p vals.first(3).join("+")
p vals.select { |v| v.is_a?(Tag) }.map(&:describe)
p vals[1].describe, vals[4].describe
h = { "k" => vals[0] }
p h["k"].upcase, h["k"].class, h["k"].kind
t = vals[0]
t2 = t
t2 << "!"
p vals[0], t.equal?(vals[0])
def tagged(x) = x
y = tagged(vals[1])
p y.class, y
def append(s, x)
  s << x
  s
end
r = append(Tag.new("a"), "b")
p r, r.class
u = append(+"plain", "c")
p u, u.class
w = vals.find { |v| v.is_a?(Tag) && v.kind == :block }
p w
p vals[0] == "em!", "em!" == vals[0], vals[0].hash == "em!".hash
p vals.map(&:to_s).first(2)
