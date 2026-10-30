# The in-place filter (reject!, select!, delete_if, keep_if) of a boxed
# Hash or Array beside a class of the program's own (here Bag) defining
# the same method: the block's own calls dispatch on their own receivers.
# `v.zero?` on a poly value took the builtin Integer#zero? for a Scalar
# too, though the Hash's arm reads only its RECEIVER as no object of the
# program's; and where Scalar#zero? answers a box the C did not build.
class Scalar
  def initialize(value) = @value = value
  def zero? = @value.zero?
  def inspect = "Scalar(#{@value.inspect})"
end

# an unset amount is neither zero nor nonzero: its zero? answers nil
class Amount
  def initialize(value) = @value = value
  def zero? = @value.nil? ? nil : @value.zero?
  def inspect = "Amount(#{@value.inspect})"
end

class Bag
  def reject!(&) = :bag_reject
  def select!(&) = :bag_select
  def delete_if(&) = :bag_delete_if
  def keep_if(&) = :bag_keep_if
end

def pick(a, i) = a[i]
vals = [1, 0, Scalar.new(0), Scalar.new(2.5), Amount.new(0), Amount.new(nil), 0.0]

h = pick([{ a: vals[0], b: vals[1], c: vals[2], d: vals[3], e: vals[4], f: vals[5], g: vals[6] }, Bag.new], 0)
h.reject! { |k, v| v.zero? }
p h
h = pick([{ a: vals[0], b: vals[1], c: vals[2], d: vals[3], e: vals[4], f: vals[5], g: vals[6] }, Bag.new], 0)
p h.select! { |k, v| v.zero? }
p pick([{ a: vals[2], b: vals[3] }, Bag.new], 0).delete_if { |k, v| v.zero? }
p pick([{ a: vals[2], b: vals[3] }, Bag.new], 0).keep_if { |k, v| v.zero? }

a = pick([vals.dup, Bag.new], 0)
a.reject! { |v| v.zero? }
p a
p pick([vals.dup, Bag.new], 0).select! { |v| v.zero? }
p pick([vals.dup, Bag.new], 0).delete_if { |v| v.zero? }
p pick([vals.dup, Bag.new], 0).keep_if { |v| v.zero? }

# the class still takes its own
p pick([{ a: vals[0] }, Bag.new], 1).reject! { |k, v| v.zero? }
p pick([vals, Bag.new], 1).select! { |v| v.zero? }
