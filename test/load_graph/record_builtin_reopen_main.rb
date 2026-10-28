# A header that reopens a builtin finds Object's constant and writes
# none, as in CRuby, at the top level and in `class Object`; a header of a
# builtin's name in another class makes a new class there and writes its
# constant.
class Integer
  def double = self * 2
end
module Comparable
  def tag = :cmp
end
class Object
  class Float
    def halve = self / 2
  end
end
module Lib
  class String
    def lib = 1
  end
end
p 3.double
p 1.tag
p Lib::String.new.lib
p Lib::String.equal?(::String)
p Object.const_defined?(:Float)
