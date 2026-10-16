# A `class << X` body's declarations and defs define X's class methods; a
# block in it that does not touch self runs as written.
class Shape
  class << self
    attr_accessor :count
    def unit = :unit
    private def hidden = :hidden
    alias_method :one, :unit
    define_method(:twice) { |v| v * 2 }
    [1, 2].each { |i| puts "step #{i}" }
  end
end

Shape.count = 3
p Shape.count, Shape.unit, Shape.one, Shape.twice(4)
p Shape.respond_to?(:hidden), Shape.respond_to?(:unit)
