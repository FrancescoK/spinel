# `def inspect(i = 0)` from a hook's class_eval text is the includer's
# inspect: p and an explicit call both use it.
module Hook
  def self.included(base)
    base.class_eval do
      class_eval "def inspect(i = 0) = \"U\#{i}\""
    end
  end
end

class U
  include Hook
end

p U.new
puts U.new.inspect
