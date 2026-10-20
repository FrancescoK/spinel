# The String `@h[k] ||= v` stores in an instance variable's Hash is the one
# the expression answers: a change made through the answer is seen through
# the Hash, in an instance's Hash, a module's own (module_function), and
# through `&&=`.
class Cache
  def initialize = @cache = {}

  def get(k)
    @cache[k] ||= k.sub("a", "b")
  end

  def again(k)
    @cache[k] &&= @cache[k] + "?"
  end
end

c = Cache.new
v = c.get("aa")
v << "!"
p c.get("aa"), v
w = c.again("aa")
w << "#"
p c.get("aa"), w

module Util
  module_function

  @names = {}

  def plural_of(given)
    @names[given] ||= given.sub(/^Given/, "Taken").sub("Mode", "Modes")
  end
end

s = Util.plural_of("GivenModeQ")
s << "!"
p Util.plural_of("GivenModeQ"), s
t = Util.plural_of("GivenMode")
p t, t.equal?(Util.plural_of("GivenMode"))
