# A boxed receiver's conversion answers a String the rule shares wrapped
# from its bytes by the dispatch's default arm.
class RuntimeError
  def to_s = +"override"
end
class FreshText
  def to_s = +"fresh"
end
x = [RuntimeError.new("message"), FreshText.new][ARGV.size]
y = x.to_s
y << "!"
p y
