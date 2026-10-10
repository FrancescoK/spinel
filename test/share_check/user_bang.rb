# A bang method the program defines on String is an ordinary call with the
# bytes as its receiver, not the builtin's change in place: the check does
# not take it for one.
class String
  def strip! = "mine"
end
s = +"x "
t = s
r = (s << "y").strip!
p r, s, t
