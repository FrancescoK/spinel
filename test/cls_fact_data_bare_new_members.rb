# spinel: share
# A bare `new` (or `self.new`) in a Data or Struct class method fills the
# members as `Klass.new` does: the class facts took only an `initialize`
# for it, which a Data or Struct has none of, so a member read back held
# no class and a boxed call on it had no arm for the class stored there.
Size = Data.define(:w, :h)
Other = Data.define(:w)
Box = Data.define(:name, :size) do
  def self.default = new(name: "box", size: Size.new(w: 3, h: 4))
  def self.explicit = self.new(name: "self", size: Size.new(w: 5, h: 6))
end
Pair = Struct.new(:left, :right) do
  def self.build = new(Size.new(w: 7, h: 8), nil)
end

[Other.new(w: 1), Box.default.size].each { |o| p o.w }
[Other.new(w: 2), Box.explicit.size].each { |o| p o.w }
[Other.new(w: 3), Pair.build.left].each { |o| p o.w }
