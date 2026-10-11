# A Data or Struct built with a member read out of an Array literal: the
# member's nil-capable temp was declared in the prelude, and the literal's
# own prelude landed inside its initializer (`sp_oint _t8 = sp_IntArray
# *_t9 = ...`), so the C did not build.
Timing = Data.define(:clock_hz, :lines)
t = Timing.new(clock_hz: [985_248, 1][0], lines: 312)
p t.clock_hz
p Timing.new([1, 2][1], 3).clock_hz
p Timing.new(lines: 4, clock_hz: [7, 8][5]).clock_hz

Pair = Struct.new(:a, :b, keyword_init: true)
p Pair.new(a: [5, 6][1], b: 1).a
