# A program that defines a RUBY_ENGINE of its own reads that constant where
# it is in scope, so no RUBY_ENGINE check is folded to the global's answer.
module Shim
  RUBY_ENGINE = "jruby"
  VALUE = RUBY_ENGINE == "spinel" ? :spinel : :jruby
  def self.engine = RUBY_ENGINE
end
p Shim::VALUE
p Shim.engine
p(RUBY_ENGINE == "spinel")
