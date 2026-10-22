# A #to_str the analysis can only pin to poly that answers a String the
# program shares (one it changes in place through another name): the
# comparison takes that String, as it takes any other. Its handle was read
# as a value of another class, a TypeError naming String itself.
class Loose
  def initialize(s, bad)
    @s = s
    @bad = bad
  end

  def to_str
    return 42 if @bad
    @s
  end

  def grow = @s << "!"
end

l = Loose.new(+"abd", false)
l.grow
t = l.to_str
t << "?"
p("abc" <=> l)
p("abc" < l)
p("abc".casecmp(l))
p("ABD!?".casecmp?(l))
p("abe".between?("abc", l))
p t
begin
  p("abc" <=> Loose.new(+"x", true))
rescue TypeError => e
  puts e.message
end
