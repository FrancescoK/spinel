# String#inspect spells a valid character that does not print by its
# codepoint, as CRuby does: a C1 control, a line or paragraph separator, an
# unassigned codepoint. A format character, a space and a letter print raw.
p "\u0080"
p "a\u009Fb"
p "  "
p "͸"
p "\u{E0080}"
p "​﻿­"
p "é　"
p "\u{1F600}"
p ["\u0085", "x\u0081y"]
puts "\u0080".inspect.bytesize
