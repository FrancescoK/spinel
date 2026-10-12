# A link of a held chain that the program defines answers what its method
# answers: `concat` below is not the String's own, so the bang after it
# works on that method's answer and s keeps the first bang's change, as in
# CRuby.
class String
  def concat(*a) = +"other"
end
def id(v) = v
s = +"ab"
r = id(s).upcase!.concat("1").downcase!
p s, r
