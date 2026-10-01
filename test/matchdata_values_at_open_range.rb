# MatchData#values_at resolves a Range's ends against the group count, as
# CRuby does: an endless or beginless end runs to the last or first group, a
# negative one counts back from the end, a begin before the whole match raises
# RangeError, and a group past the last reads nil. Read raw, an endless Range
# ran the loop to INTPTR_MAX and never returned.
md = /(.)(.)(\d+)(\d)/.match("THX1138: The Movie")
p md.values_at(0..)
p md.values_at(1..)
p md.values_at(4...)
p md.values_at(6..)
p md.values_at(..2)
p md.values_at(...2)
p md.values_at(..-6)
p md.values_at(3..7)
p md.values_at(6..7)
p md.values_at(-2..)
p md.values_at(-5..-4)
p md.values_at(2..1)
p md.values_at(0, 2..3, -1)
p((md.values_at(-6..2) rescue $!))
p((md.values_at(-6..) rescue $!))
"ab12" =~ /(\w)(\d)/
p $~.values_at(1..), $~.values_at(..-2)
