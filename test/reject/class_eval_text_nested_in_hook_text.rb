# A class_eval text inside a hook's class_eval text reads the hook's local
# `x`: the hook's frame is not known where its code is spliced, so the
# inner text is not grafted either. Not grafted.
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
