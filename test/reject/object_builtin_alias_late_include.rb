# An alias of an Object method keeps the builtin in CRuby when a module the
# class includes after it defines the method; the builtin call past that
# method is served for dup and clone only, so this one is refused.
# spinel: reject-builtin-class: K#old_to_s: alias of the builtin to_s that the class later overrides is not supported
module Named
  def to_s = "named"
end
class K
  alias old_to_s to_s
  include Named
end
p K.new.old_to_s.start_with?("#<K")
