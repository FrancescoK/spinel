# spinel: reject-subclass: a def under a condition only the run time decides, of a name another method answers
# When the branch does not run, B#foo is A's (CRuby: :a); which method answers
# is not known at compile time, so the def is refused rather than standing
# whatever the condition said.
class A
  def foo = :a
end
class B < A
  if ENV["SPINEL_TEST_UNSET_VARIABLE"]
    def foo = :b
  end
end
p B.new.foo
