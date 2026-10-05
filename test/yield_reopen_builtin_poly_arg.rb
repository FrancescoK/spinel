# A yield site beside an Array reopen of a builtin name answers its own
# builtin's value when the call's argument is boxed: the String site's
# include? is a Boolean, not the reopen's Symbol. The per-site answer for
# a boxed argument was declined, the yield kept the reopen's typing, and
# "abc".include?("b") printed :never.
class Array
  def include?(x) = :never
end
def inc(v) = yield.include?(v)
v = ARGV.size > 5 ? 1 : "b"
p inc(v) { [1, 2] }
p inc(v) { "abc" }
p inc("c") { "abc" }
class Array
  def count(x) = :never
  def start_with?(x) = :never
  def delete(x) = :never
end
def cn(v) = yield.count(v)
def sw(v) = yield.start_with?(v)
def dl(v) = yield.delete(v)
v = ARGV.size > 5 ? 1 : "b"
p cn(v) { [1, 2] }
p cn(v) { "abcb" }
p sw(v) { [1] }
p sw(v) { "bc" }
p dl(v) { [1] }
p dl(v) { +"abc" }
class Hash
  def key?(x) = :hk
end
def hk(v) = yield.key?(v)
p hk(v) { {a: 1} }
