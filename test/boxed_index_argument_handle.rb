# An object's indexer and a callable's [] receive a shared String argument
# itself. Reading its bytes as a builtin Hash key must not copy these calls.
class IndexIdentity
  def [](value) = value
end

s = +"key"
t = s
t << "!"
key = [s, 0][ARGV.size]
object = [IndexIdentity.new, 0][ARGV.size]
p object[key].equal?(s)
callable = [->(value) { value }, 0][ARGV.size]
p callable[key].equal?(s)
curried = [->(a, b) { a.equal?(b) }.curry, 0][ARGV.size]
p curried[key][s]
