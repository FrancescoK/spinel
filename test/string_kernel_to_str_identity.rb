# Kernel#String of an object answering #to_str is the String #to_str answers,
# itself, not a copy of it: as a block's tail, a proc's answer and an Array's
# element, beside a String and nil.
class String
  def pm(a) = yield(a)
end
class ToStr
  def initialize(s) = (@s = s)
  def to_str = @s
end

s = +"base"
ts = ToStr.new(s)
r = "a".pm(ts) { |v| String(v) }
r << "!"
p s, r.equal?(s)
r = "a".pm(s) { |v| String(v) }
p r.equal?(s)
p "a".pm(nil) { |v| String(v) }

pr = proc { |v| String(v) }
r = pr.call(ts)
r << "?"
p s, r.equal?(s)
r = pr.call(nil)
p r, r.frozen?
r = pr.call(4)
r << "x"
p r

a = [pr.call(ts), 1]
a[0] << "#"
p s, a[0].equal?(s)
