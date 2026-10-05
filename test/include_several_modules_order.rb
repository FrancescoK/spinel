# `include A, B` puts A in front of B, as `extend A, B` does: A's method is
# found first and its super reaches B's.
module Plain
  def hi = "plain"
end

module Fancy
  def hi = "fancy " + super
end

class Both
  include Fancy, Plain
end

class Each
  include Plain
  include Fancy
end

p Both.new.hi
p Both.ancestors.take(3)
p Each.new.hi
p Each.ancestors.take(3)
