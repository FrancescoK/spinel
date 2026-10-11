# A block that becomes a proc of its own (its `each` is a dispatch over two
# classes) and stores a String into a shared-String ivar converts it in
# the proc, not in front of the dispatch, where the block's parameter does
# not exist yet (#8525).
class Gadget
  def each
    yield "label", String.new("gadget")
  end
end

class Widget
  # @rbs @label: String?

  #: (untyped) -> void
  def initialize(source)
    @label = nil
    source.each do |k, v|
      @label = v if k == "label"
    end
  end

  #: () -> String?
  def shout
    l = @label
    l << "!" unless l.nil?
    l
  end
end

h = { "label" => String.new("hash") }
p Widget.new(h).shout
p Widget.new(Gadget.new).shout
