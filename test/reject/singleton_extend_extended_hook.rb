# obj.extend(M) mixes M into the object's own class when the program is
# compiled; M.extended would have to run at the call, so it is refused.
module Hooked
  def self.extended(base) = puts("extended")
  def hi = "hi"
end
o = Object.new
o.extend(Hooked)
p o.hi
