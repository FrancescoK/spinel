# Annotations inside a `Data.define` block belong to the data class.
Point = Data.define(:x, :y) do
  #: (untyped) -> untyped
  def shift(d)
    x + d
  end
end

p Point.new(x: 1, y: 2).shift(3)
