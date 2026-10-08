# The same route as string_identity_return_mutation, through a method's own
# parameter: the caller passes a variable it reads again, so the copy the
# append lands in is seen there ("seed!" in CRuby).
class D
  def id(x) = x
  def entry(data)
    w = id(data)
    w << "!"
    nil
  end
end
s = +"seed"
D.new.entry(s)
p s
