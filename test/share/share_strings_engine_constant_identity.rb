# The engine's String constants (RUBY_ENGINE, RUBY_VERSION, ...) are each
# one frozen object, however often they are read: handed to a parameter a
# method can append to, stored into a container, or bound through a
# keyword, each is still that object. Under --share-strings a parameter
# that holds the shared handle took a new handle of the constant's bytes.
def keep(s)
  s << "!" unless s.frozen?
  s
end
def kw(s:)
  s << "?" unless s.frozen?
  s
end
m = +"m"
p keep(RUBY_ENGINE).equal?(RUBY_ENGINE), keep(RUBY_VERSION).equal?(RUBY_VERSION)
p kw(s: RUBY_PLATFORM).equal?(RUBY_PLATFORM), keep(RUBY_COPYRIGHT).frozen?
a = [1, RUBY_ENGINE]
p a[1].equal?(RUBY_ENGINE), keep(a[1]).equal?(RUBY_ENGINE)
p keep(m), kw(s: m).equal?(m), m
