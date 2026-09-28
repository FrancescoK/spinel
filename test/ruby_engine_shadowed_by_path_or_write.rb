# `Mod::RUBY_ENGINE ||= v` looks only in Mod, so it defines a RUBY_ENGINE of
# Mod's own that the reads inside it see; no check is folded.
module Compat
  Compat::RUBY_ENGINE ||= "truffleruby"
  VALUE = RUBY_ENGINE == "spinel" ? :spinel : :truffleruby
end
p Compat::VALUE
