# The text reads the hook's parameter `base`: the splice puts the includer
# in its place in the hook's own code, but the graft names no local for it
# in the text. Not grafted.
module Hook
  def self.included(base)
    base.class_eval do
      class_eval "B = base"
    end
  end
end

class U
  include Hook
end
p U::B
