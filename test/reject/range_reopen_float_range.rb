# A method the program defines in Range has a body for an Integer Range
# alone: a Range of Floats had no such method and raised NoMethodError
# (CRuby prints :foo), so the call is refused, not answered wrongly.
class Range
  def foo = :foo
end
p (1..3).foo
p (1.0..2.0).foo
