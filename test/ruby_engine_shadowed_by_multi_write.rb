# A RUBY_ENGINE defined as a multiple-assignment target shadows the global as
# much as a plain write does, so no check is folded to the global's answer.
module Shim
  VERSION, RUBY_ENGINE = 1, "jruby"
  VALUE = RUBY_ENGINE == "spinel" ? :spinel : :jruby
  def self.engine = RUBY_ENGINE != "spinel" ? RUBY_ENGINE : :spinel
end
p Shim::VALUE
p Shim.engine
