# A builtin exception reopening must run on the boxed exception too.
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
