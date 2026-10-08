# A fresh user method does not prove the builtin arm of a boxed call fresh.
# String#to_s returns the receiver, so copying it would split these aliases.
class FreshText
  def to_s = "fresh"
end
s = +"source"
x = [s, FreshText.new][ARGV.size]
y = x.to_s
y << "!"
p [s, y, s.equal?(y)]
