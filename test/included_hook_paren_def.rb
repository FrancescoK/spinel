# A hook's class_eval text spliced into its includer is lowered as the
# includer's own code is: `def m = (a; b)`, an endless def whose body is a
# parenthesized sequence, defines m in the includer.
module Hook
  def self.included(base)
    base.class_eval do
      class_eval "def m = (x = 1; x + 1)"
    end
  end
end

class U
  include Hook
end

p U.new.m
