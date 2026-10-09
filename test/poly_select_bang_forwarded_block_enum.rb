# A method that answers an Enumerator without a block and hands its block on
# to select! on a receiver known only at run time: spliced into the
# Enumerator's body, the forward named a block variable that body does not
# have, and the C did not build.
class Box
  def initialize(h) = @h = h
  def pick = [@h, 1].first
  def select(*args, &block)
    return to_enum(:select) unless block_given?
    pick.tap { |hash| hash.select!(*args, &block) }
  end
end
b = Box.new({"a" => 1, "b" => 5})
p b.select { |k, v| v > 3 }
p b.select.class
