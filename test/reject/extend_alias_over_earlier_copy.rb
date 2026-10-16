# A module extended after another takes the class method its alias names
# ahead of the earlier module's copy; the alias keeps the later module's
# body, which the class's own class method of the target hides, so it is
# refused as with no earlier module.
# spinel: reject-builtin-class: K.copied: alias in the extended module M of a class method K defines itself is not supported
module N
  def copied = "N#copied"
end
module M
  def original = "M#original"
  alias copied original
end
class K
  def self.original = "K.original"
  extend N
  extend M
end
p K.copied
