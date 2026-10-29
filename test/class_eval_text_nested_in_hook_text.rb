# A class_eval text inside a hook's class_eval text reads the hook's local
# `x`: the inner text runs in the frame the outer one makes, inside the
# hook's.
module Hook
  def self.included(base)
    x = 42
    base.class_eval do
      class_eval "class_eval 'X = x'"
    end
  end
end

class U
  include Hook
end
p U::X
