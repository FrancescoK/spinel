# Comparable shadows builtin equality; Numeric's spaceship uses identity.
class Numeric
  def default_marker = true
end
class NumericDefault < Numeric
  def ==(other) = true
end
StructDefault = Struct.new(:a) do
  include Comparable
end
DataDefault = Data.define(:a) do
  include Comparable
end
class ExceptionDefault < StandardError
  include Comparable
end
class ObjectDefault
  include Comparable
  def ==(other) = true
end
xs = [NumericDefault.new, NumericDefault.new,
      StructDefault.new(1), StructDefault.new(1),
      DataDefault.new(a: 1), DataDefault.new(a: 1),
      ExceptionDefault.new("m"), ExceptionDefault.new("m"),
      ObjectDefault.new, ObjectDefault.new, 0]
[[0, 1], [2, 3], [4, 5], [6, 7], [8, 9]].each do |i, j|
  p(xs[i] <=> xs[j])
  begin; p(xs[i] <= xs[j]); rescue ArgumentError => e; p e.class; end
  begin; p [xs[i], xs[j]].sort.size; rescue ArgumentError => e; p e.class; end
end
# Statically known receivers also retain each family's default comparison.
begin; p [NumericDefault.new, NumericDefault.new].sort.size; rescue ArgumentError => e; p e.class; end
begin; p [StructDefault.new(1), StructDefault.new(1)].sort.size; rescue ArgumentError => e; p e.class; end
begin; p [DataDefault.new(a: 1), DataDefault.new(a: 1)].sort.size; rescue ArgumentError => e; p e.class; end
begin; p [ExceptionDefault.new("m"), ExceptionDefault.new("m")].sort.size; rescue ArgumentError => e; p e.class; end
p [ObjectDefault.new, ObjectDefault.new].sort.size
# A declined default calls program equality once. Object keeps its fallback.
class CountedComparableDefault
  include Comparable
  def ==(other)
    $default_equality_calls += 1
    false
  end
end
class CountedObjectDefault
  def ==(other)
    $default_equality_calls += 1
    false
  end
end
values = [CountedComparableDefault.new, CountedComparableDefault.new,
          CountedObjectDefault.new, CountedObjectDefault.new, 0]
[[0, 1], [2, 3]].each do |i, j|
  $default_equality_calls = 0
  p(values[i] <=> values[j])
  p $default_equality_calls
end
