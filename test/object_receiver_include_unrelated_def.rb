# A method named include in an unrelated class does not stand in for
# Object.include: the statement mixes M into Object, and Foo's own include
# still answers for a Foo.
class Foo
  def include(m) = :mine
end
module M; def mm = 7; end
Object.include M
p 1.mm
p Foo.new.include(1)
