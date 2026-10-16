# A program's own String#equal? is a method like any other: its argument
# is no identity operand, and a variable that holds no shared handle can
# be passed to it beside one that does.
class String
  def equal?(o) = (o << "!"; :mine)
end
s = +"a#{ARGV.size}"
t = s.dup
p s.equal?(t), s.equal?(s)
p s, t
u = +"u"
p u.equal?(u), u
