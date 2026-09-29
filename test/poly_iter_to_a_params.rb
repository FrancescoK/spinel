# A poly receiver walked by an Enumerable lowering (`other.all?` where `other`
# widened to poly) is normalized through its class's #to_a. That to_a may take
# a rest and/or a block -- the forwarding shape `delegate :to_a, to: :@m`
# produces -- so its C function has the rest/block parameters; the arm passes
# an empty rest and no block instead of calling it with self alone.
class Members
  include Enumerable
  def initialize(a) = @m = a
  def each(*a, &b) = a.empty? ? @m.each(&b) : @m.each(*a, &b)
  def to_a(*a, &b) = a.empty? ? @m.to_a(&b) : @m.to_a(*a, &b)
end
class Blocky
  include Enumerable
  def initialize(a) = @m = a
  def each(&b) = @m.each(&b)
  def to_a(&b) = b ? @m.map(&b) : @m
end
class Plain
  include Enumerable
  def initialize(a) = @m = a
  def each(&b) = @m.each(&b)
  def to_a = @m
end
class Checker
  def initialize(allowed) = @allowed = allowed
  # `other` widens to poly: every call site passes a different class.
  def covers?(other)
    other.all? { |x| @allowed.include?(x) }
  end
end
c = Checker.new([1, 2, 3])
things = [Members.new([1, 2]), Members.new([1, 9]), Blocky.new([3]), Blocky.new([4]),
          Plain.new([2, 3]), Plain.new([7]), [3, 1], [8]]
things.each { |t| p c.covers?(t) }
# The same to_a reached through a poly receiver directly: the forwarding def
# then also exists as its proc-form clone, which the arms must name.
things.each { |t| p t.to_a }
