# spinel: share
# spinel: gc-minor
# A class arm boxes borrowed, fresh and nil returns by the same return facts.
class ClassTail
  def self.take(value, which)
    return nil if which == 2
    return value + "\0new" if which == 1
    value << "!"
  end
end
class OtherClassTail
  def self.take(value, which)
    return nil if which == 2
    return value + "\0other" if which == 1
    value << "?"
  end
end
class IntegerTail
  def take(value, which)
    17
  end
end
[ClassTail, OtherClassTail, IntegerTail.new].each do |receiver|
  [0, 1, 2].each do |which|
    value = +"s"
    held = value
    result = receiver.take(value, which)
    if result.is_a?(String)
      p result.equal?(value)
      result << "."
      p [result.bytes, held]
    else
      p result
    end
  end
end
