# After a `private` without arguments, an inlined `def` would be private: the
# call is not expanded (its run-time module_eval refused), so the method a
# module_eval'd template defines stays public.
module Defs
  def reader(n) = module_eval("def #{n}; 1; end")
end
class Box
  extend Defs
  private
  reader :size
end
p Box.new.size
