# A conditional update leaves an earlier definite assignment present,
# including nil, in bare and scoped constant reads.
p :before
NOTHING = nil
NOTHING &&= 1
p NOTHING
ZERO = 0
ZERO ||= 99
p ZERO
module PresenceUpdates
  VALUE = 2
  VALUE &&= 3
  p VALUE
end
p PresenceUpdates::VALUE
