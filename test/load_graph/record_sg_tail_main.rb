# A class body's call of a method the program adds to Class or Module
# searches its singleton's ancestors, which end in those classes' instance
# methods. These write the class's instance variable: code the record
# cannot follow (opaque).
class Class
  def tag(n) = @tag = n
end
class Module
  def note(n) = @note = n
end
class Foo
  tag 3
end
module Bar
  note 4
end
p Foo.tag(5)
p Bar.name
