# spinel: reject-subclass: a method defined in an instance_eval block
# Inside Host, `Root` is Host::Root, which holds no Leaf: CRuby raises
# NameError for Root::Leaf and does not look for the top-level Root::Leaf.
# The call is refused rather than reopening the top-level class.
module Root
  class Leaf; end
end
class Host
  module Root; end
  Root::Leaf.instance_eval { def tag = :leaf }
end
p Root::Leaf.respond_to?(:tag)
