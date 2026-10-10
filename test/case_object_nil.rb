# spinel: gc-stress
# spinel: share
class BranchTag
  def initialize(s) = (@s = s)
  def to_s = @s
end
def no_else(i)
  t = case i
      when 1
        x = i * 3
        BranchTag.new("w#{x}")
      end
  t.nil? ? "nil" : t.to_s
end
def nil_pattern(i)
  t = case i
      in 1
        x = i * 3
        BranchTag.new("p#{x}")
      in _
        nil
      end
  t.nil? ? "nil" : t.to_s
end
def empty_arm(i)
  t = case i
      when 0
      when 1
        BranchTag.new("one")
      else
        nil
      end
  t.nil? ? "nil" : t.to_s
end
def empty_else(i)
  t = case i
      in 1
        BranchTag.new("one")
      else
      end
  t.nil? ? "nil" : t.to_s
end
def required_pattern(i)
  t = case i
      in 1
        BranchTag.new("one")
      end
  t.to_s
rescue NoMatchingPatternError
  "unmatched"
end
puts no_else(1), no_else(0), nil_pattern(1), nil_pattern(0)
puts empty_arm(0), empty_arm(1), empty_arm(2), empty_else(0), empty_else(1)
puts required_pattern(0), required_pattern(1)
