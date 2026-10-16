# `+` of a builtin String constant or of a freeze's answer is a new String:
# a change to it leaves the constant as it was (#9258)
y = +RUBY_PLATFORM
y << "?"
z = ARGV.empty? ? RUBY_PLATFORM : +"n"
p z.equal?(RUBY_PLATFORM), y.equal?(RUBY_PLATFORM)
x = +RUBY_ENGINE.freeze
x << "!"
p x.equal?(RUBY_ENGINE), RUBY_ENGINE.frozen?
s = +"abc"
t = +s.freeze
t << "!"
p s, t, s.freeze.equal?(s)
