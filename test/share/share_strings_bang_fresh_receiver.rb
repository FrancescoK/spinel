# Under --share-strings a bang method on a new String (`pick(s).upcase!`,
# where pick answers `value + ""`) answers that new String or nil, which no
# other name holds: two such values are two Strings, and changing one
# leaves the other and the String the new one was made from as they are.
def pick(value, missing)
  return nil if missing
  value + ""
end
s = +"ab"
r = pick(s, false).upcase!
r << "c"
p s, r
r2 = pick(s, true)&.upcase!
p r2
r3 = pick(s, false).upcase!
r3 << "d"
p r3, r, r3.equal?(r)
r4 = (s + "").downcase!
p r4
r5 = pick(+"QQ", false).upcase!
p r5
r6 = pick(s, false).upcase!.downcase!
r6 << "e"
p r6, s
