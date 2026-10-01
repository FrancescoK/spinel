# A method the program adds to Object is a MatchData's too: on $~ (nil after
# a miss), Regexp.last_match, a MatchData local and inside a method, with and
# without arguments. ruby/spec reaches it through `$~.should == nil`.
class Object
  def me = self
  def pair(x) = [self, x]
  def tag = "<#{inspect}>"
end
"abc" =~ /z/
p $~.me, $~.tag
"abc" =~ /(b)/
p $~.me, $~.me[1], $~.pair(1), $~.tag
m = "xyz".match(/y/)
p m.me, m.me.class, m.pair(:k)
"q1" =~ /\d/
p Regexp.last_match.me, Regexp.last_match.tag
def last_digit(s) = (s =~ /\d/; $~.me)
p last_digit("a7"), last_digit("aa")
