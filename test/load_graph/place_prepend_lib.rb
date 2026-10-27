module Loud
  def hi = "LOUD " + super
end
class Foo
  prepend Loud
end
