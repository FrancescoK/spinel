# A RUBY_ENGINE comparison is folded into true or false in place, which
# turns its call into a literal without adding a node. The compiler's
# list of nodes by kind still counted the folded node among the calls,
# so the String sharing walk read a name the literal does not have and
# the compiler crashed. That walk now also tests for a missing name; the
# program stays as a guard. The answers here do not depend on the engine.

ENV.delete("SPINEL_KINDIDX_UNSET")

def env_or_default(name)
  return "d" unless RUBY_ENGINE == "spinel"
  ENV.fetch(name, "d")
end
p env_or_default("SPINEL_KINDIDX_UNSET")

def deleted(name)
  return nil if RUBY_ENGINE != "spinel"
  ENV.delete(name)
end
p deleted("SPINEL_KINDIDX_UNSET")

p(RUBY_ENGINE == "spinel" ? ENV["SPINEL_KINDIDX_UNSET"] : nil)
