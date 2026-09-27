# RUBY_ENGINE is "spinel" in every program spinel compiles, so a comparison
# of it with a string literal is a constant and the branch it rules out never
# runs. That branch is dropped before analysis: code written for another
# engine (an eval backend, a JRuby or TruffleRuby shim) compiles away instead
# of being refused. The expected output is spinel's, not CRuby's.

def check(code)
  if RUBY_ENGINE == "spinel"
    :skipped
  else
    eval(code, binding)
  end
end
p check("1 + 1")

p(RUBY_ENGINE != "spinel" ? eval("1") : :folded)
p("jruby" == RUBY_ENGINE ? binding : :not_jruby)

unless RUBY_ENGINE == "spinel"
  eval("puts 1")
else
  p :unless_else
end

x = 5
r = if RUBY_ENGINE == "jruby"
  binding.local_variable_get(:x)
elsif x > 3
  :big
else
  :small
end
p r

class Shim
  if RUBY_ENGINE == "truffleruby"
    def speed = Truffle::Interop.whatever
  else
    def speed = 42
  end
end
p Shim.new.speed

p :modifier if RUBY_ENGINE == "spinel"
v = "spinel"
p v == "spinel"
