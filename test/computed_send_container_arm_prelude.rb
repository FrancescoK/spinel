# A computed send whose receiver may be a class value with a class method
# of that name or a builtin container: the container's arm runs the
# builtin's call on the receiver it was handed -- its argument check
# included -- not on a value read before the receiver was.
module State
  class << self
    def delete(key = :none, &block) = block ? block.call(key) : "deleted #{key}"
  end
end
class Path
  def delete = "path gone"
end
class Box
  def initialize(v, m) = (@v = v; @m = m)
  def go = @v.__send__(@m)
end
p State.delete(:x) { |k| "blk #{k}" }
p Box.new(State, :delete).go, Box.new(Path.new, :delete).go
p Box.new([1, 2], :size).go, Box.new({a: 1}, :size).go
[[1], {a: 1}].each do |v|
  begin
    Box.new(v, :delete).go
  rescue ArgumentError => e
    p [v.class, e.class, e.message]
  rescue NoMethodError => e
    p [v.class, e.class]
  end
end
