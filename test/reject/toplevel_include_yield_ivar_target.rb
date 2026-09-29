# A method of a module included at the top level runs with self bound to
# main, which holds no module state, so one that touches an instance variable
# is refused (#3775). A multiple-assignment target (`@a, @b = ...`) is such a
# write too. Missed by the check, the yielding method was inlined and the C
# referred to a `self` that does not exist at the top level.
module Pair
  def pair
    @a, @b = yield, 2
    :ok
  end
end

include Pair
p pair { 1 }
