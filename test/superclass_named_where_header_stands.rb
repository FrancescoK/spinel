# a superclass constant names the class it names where the header stands:
# `class H < B` in Outer before Outer has a B of its own is the top-level
# B, and after it is Outer::B
class B
  def who = "top B"
end
module Outer
  class H < B; end
end
module Outer
  class B
    def who = "Outer::B"
  end
  class J < B; end
end
p Outer::H.superclass, Outer::H.new.who
p Outer::J.superclass, Outer::J.new.who
