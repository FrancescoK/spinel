# The block a String reopening's yielding method is given can have a rescue
# or ensure clause of its own (`do |v| ... rescue ... end`): its body is a
# begin, and the value the block answers is the begin's: the body's last
# statement, a rescue clause's, or the else clause's. A shared String any of
# them answers is the String itself, so a change through the call's value
# reaches it, as in CRuby.
class String
  def pm(a) = yield(a)
end

s = +"rr"
r = "a".pm(s) do |v|
  v
rescue
  +"z"
end
r << "1"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) do |v|
  Integer("q")
rescue
  v
end
r << "2"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) do |v|
  v
ensure
  nil
end
r << "3"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) do |v|
  Integer("1")
  +"unused"
rescue
  +"z"
else
  v
end
r << "4"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) do |v|
  next v if v.size > 1
  +"z"
rescue
  +"y"
end
r << "5"
p s, r.equal?(s)
