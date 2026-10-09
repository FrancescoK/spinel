# Annotations inside a `Struct.new` block belong to the struct's class, not to
# the class or file around it.
class Outer
  def initialize
    @note = nil
  end

  attr_reader :note

  Pair = Struct.new(:a, :b) do
    #: (untyped) -> untyped
    def scaled(k)
      a * k
    end

    # @rbs @note: String?

    attr_reader :note #: String?

    def init_note
      @note = nil
    end
  end
end

pr = Outer::Pair.new(2, 3)
p pr.scaled(4)
pr.init_note
p pr.note
p Outer.new.note
