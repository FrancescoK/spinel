# An alias of Object#respond_to? the class then defines itself keeps the
# builtin in CRuby; a call past the class's own respond_to? is not served,
# so this one is refused.
# spinel: reject-builtin-class: K#respond_to_without_dyn?: alias of the builtin respond_to? that the class later overrides is not supported
class K
  def known = 1
  alias_method :respond_to_without_dyn?, :respond_to?
  def respond_to?(m, priv = false) = m.to_s.start_with?("dyn_") || respond_to_without_dyn?(m, priv)
end
p K.new.respond_to?(:known)
