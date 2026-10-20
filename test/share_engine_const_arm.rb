# An engine String constant beside a new String in a variable the rule
# shares (a conditional's arms, an Array literal): the constant is one
# frozen object, as a frozen literal is, and its handle its own; the
# variable's write was refused as a route that cannot carry the handle
# (#9258).
z = ARGV.empty? ? RUBY_PLATFORM : +"n"
z << "!" unless z.frozen?
p z.equal?(RUBY_PLATFORM), z.frozen?
y = ARGV.empty? ? +"m" : RUBY_VERSION
y << "?" unless y.frozen?
p y
k = [RUBY_RELEASE_DATE, +"e"]
k.each { |s| s << "." unless s.frozen? }
p k[1], k[0].equal?(RUBY_RELEASE_DATE), k[0].frozen?
w = RUBY_VERSION
v = w
p v.equal?(RUBY_VERSION)
