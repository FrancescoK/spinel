# A class whose #hash may answer nil types every boxed receiver's #hash as a
# nullable Integer. The key of a builtin value is never nil, and it folds
# into an accumulator like any Integer.
class Tag
  def initialize(name) = @name = name
  def hash = @name&.size
end

total = 0
[1, "a", :b, Tag.new("xy")].each { |x| total ^= x.hash }
p total.is_a?(Integer)
p Tag.new("xy").hash
p Tag.new(nil).hash
