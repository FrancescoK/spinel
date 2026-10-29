# `m.const_set(:X, v)` with m a parameter sets X in whatever module m holds.
# Box and Crate each hold an X, and constants are compile-time globals, so
# which one this sets is not known at compile time: refused (CRuby prints 2
# and 10), not written into either.
module Box
  X = 1
end
module Crate
  X = 10
end
def set_x(m, v) = m.const_set(:X, v)
set_x(Box, 2)
p Box::X, Crate::X
