# An instance alias in a module keeps the module's body; in a class that
# extends the module and defines that method itself, no class method holds
# the module's body, so the alias is refused.
# spinel: reject-builtin-class: K.copied: alias in the extended module M of a class method K defines itself is not supported
module M
  def original = "M#original"
  alias copied original
end
class K
  extend M
  def self.original = "K.original"
end
p K.copied, K.original
