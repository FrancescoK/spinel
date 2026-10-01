# `Kernel.warn(msg, uplevel: 0)` is the same call as a bare warn: its prefix
# is the location the call is written at.
Kernel.warn("explicit receiver", uplevel: 0)
def note(x) = Kernel.warn("note #{x}", uplevel: 0)
note(1)
warn(["a", ["b"]], uplevel: 0)
puts "done"
