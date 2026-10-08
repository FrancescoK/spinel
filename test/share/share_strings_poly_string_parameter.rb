# A boxed call holds shared String arguments as handles. A plain String
# parameter takes a rooted read of that handle, including nil and frozen
# values. Two such reads survive each other's allocation and a later
# argument that rebinds the source slots.
class FirstReader
  def read(left, right, ignored = "default" * 100)
    padding = "x" * 500
    "first:#{left}:#{right}:#{left.frozen?}:#{right.frozen?}:#{padding.size}:#{ignored.to_s.size}"
  end
end
class SecondReader
  def read(left, right, ignored = "default" * 100)
    padding = "y" * 500
    "second:#{left}:#{right}:#{left.frozen?}:#{right.frozen?}:#{padding.size}:#{ignored.to_s.size}"
  end
end

[FirstReader.new, SecondReader.new].each do |reader|
  $left = +"left"
  $right = +"right"
  left_alias = $left
  right_alias = $right
  $left << "!"
  $right << "?"
  p reader.read($left, $right, ($left = +"new-left"; $right = +"new-right"; nil))
  p left_alias, right_alias, $left, $right
  p reader.read($left, $right, ($left << "!"; $right << "?"; nil))
  p reader.read($left, $right)
  $left = "frozen-left"
  $right = "frozen-right"
  p reader.read($left, $right, nil)
  $left = nil
  $right = nil
  p reader.read($left, $right, nil)
end
