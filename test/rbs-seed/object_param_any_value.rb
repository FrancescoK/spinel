# spinel: rbs-seed-run
# An --rbs `Object` (or `BasicObject`) parameter takes any value, as
# `untyped` does, in a program that reopens `class Object` too: the reopen
# made Object a class of the program's, and the seed pinned the parameter
# to that object, which a Float or a String could not be stored in (#8407).
class Object
  def gadget_tag
    "gadget"
  end
end

module GaugeSeed
  def self.text?(text)
    text.length > 0
  end

  def self.valid?(value)
    return true if value.is_a?(Integer) || value.is_a?(Float)
    value.is_a?(String) && text?(value)
  end

  def self.wrap(value) = [value]
end

p GaugeSeed.valid?(2.5)
p GaugeSeed.valid?("12")
p GaugeSeed.valid?(:x)
p GaugeSeed.wrap(1), GaugeSeed.wrap("s")
p 3.gadget_tag
