# `def inspect(i = 0)` in a hook's class_eval block is the includer's
# inspect: p and an explicit call both use it.
module Hook
  def self.included(base)
    base.class_eval do
      def inspect(i = 0) = "U#{i}"
    end
  end
end

class U
  include Hook
end

p U.new
puts U.new.inspect
