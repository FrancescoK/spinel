# An alias of an Object method the class then defines itself keeps the
# builtin in CRuby; a program object's builtin call past the class's own
# method is served for dup and clone only, so this one is refused.
# spinel: reject-builtin-class: K#old_to_s: alias of the builtin to_s that the class later overrides is not supported
class K
  alias old_to_s to_s
  def to_s = "mine"
end
p K.new.old_to_s.start_with?("#<K")
