# spinel: reject-subclass: a def under a condition only the run time decides, of a name another method answers
# When the branch does not run, Child#foo is the reader Parent declares
# (CRuby: :inherited); an accessor answers the name as a def would, so the
# def is refused rather than raising NoMethodError then.
class Parent
  attr_reader :foo
  def initialize = @foo = :inherited
end
class Child < Parent
  if ENV["SPINEL_TEST_UNSET_VARIABLE"]
    def foo = :child
  end
end
p Child.new.foo
