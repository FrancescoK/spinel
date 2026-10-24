# Enumerator#with_object(memo) { } on what a method answers without a
# block: its `to_enum` beside its `self`, a value known only at run time.
# The call was compiled into the NoMethodError for `with_object` on an
# Enumerator; it is each_with_object's walk when the value is an Enumerator
# (the memo is the answer, a `break` leaves with its value), and the call
# as written for anything else: another class's own with_object, or
# CRuby's NoMethodError. Blockless, `.each { }` on it is the same call.
class Walk
  def initialize(xs) = @xs = xs
  def each_item(&blk)
    return to_enum(:each_item) unless blk
    @xs.each(&blk)
    self
  end
end
class Own
  def with_object(m) = yield(:own, m) && [:own, m]
end
w = Walk.new([1, 2, 3])
memo = w.each_item.with_object([]) { |x, acc| acc << x * 10 }
p memo, memo.class
p w.each_item.with_object({}) { |x, h| break :early if x == 2; h[x] = 1 }
vals = [w.each_item, [4, 5], Own.new]
vals.each do |v|
  r = v.with_object([]) { |x, acc| acc << x }
  p r
rescue NoMethodError => e
  puts "NoMethodError #{e.name}"
end
p w.each_item.with_index(1).with_object([]) { |(x, i), acc| acc << x * i }
p w.each_item.with_object({}).each { |x, h| h[x] = x.to_s }
p w.each_item.each_with_object([]) { |x, acc| acc << -x }
