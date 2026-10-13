# A `return` in a define_method's arguments runs in the included hook and
# leaves it, so the hook is called, not spliced into the class body (where
# the return would end the program). Called, its define_method on the class
# it was given is refused.
module Ext
  def self.included(base)
    base.class_eval do
      define_method(:kind, (return if base.name == "B"; proc { :k }))
    end
  end
end
class A; include Ext; end
class B; include Ext; end
p A.new.kind
puts "done"
