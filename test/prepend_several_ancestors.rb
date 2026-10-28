# `prepend A, B` prepends B first, then A, so A stands in front: ancestors
# lists A, B, the class; a later `prepend B, C` goes ahead of both

module A; def hi = "a"; def who = "A>" + super; end
module B; def hi = "b"; def who = "B>" + super; end
module C; def who = "C>" + super; end
class Bar
  def who = "Bar"
  prepend A, B
end
class Baz
  def who = "Baz"
  prepend A
  prepend B, C
end
class Qux
  def who = "Qux"
  include A, B
end
p Bar.ancestors.take(3), Bar.new.hi, Bar.new.who
p Baz.ancestors.take(4), Baz.new.who
p Qux.ancestors.take(3), Qux.new.hi
p Bar.new.is_a?(B), Bar.include?(A)
