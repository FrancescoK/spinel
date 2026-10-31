# A class-body macro whose block destructures its parameter: the form writes it
# after the row that flattens such parameters has run on the macro's block.
class Base
  def self.mk(n) = define_method(n) { |(x, y)| [x, y] }
end
class Foo < Base
  mk :a
end
p Foo.new.a([1, 2])
