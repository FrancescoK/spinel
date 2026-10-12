# `x.message` on a value of no static class (a box) answers the message
# String the exception keeps, itself, as an exception's typed read does;
# on any other value the read raises NoMethodError.
s = +"boom"
s << "!"
begin
  raise s
rescue => e
  y = [e, 1].first
  z = 2
  z = y.message
  p z.equal?(s), z
  z << "?"
  p s
end
x = [s].first(1)
x = s if s.size > 100
x = x.message if x.is_a?(Exception)
p x
q = ARGV.size == 0 ? "plain" : e
begin
  q = q.message
rescue NoMethodError => ex
  p ex.class
end
