# spinel: gc-minor
# ENV.delete's missing-key block answers its value itself: a key the block
# hands back is the same String through every name.
key = +"SPINEL_SHARE_ENV_DELETE_BLOCK_VALUE"
ENV.delete(key)
value = ENV.delete(key) { |missing| missing }
value << "?"
p key, value.equal?(key)
key << "!"
p value

# a present key answers the variable's own frozen copy
ENV["SPINEL_SHARE_ENV_DELETE_BLOCK_SET"] = "set"
present = +"SPINEL_SHARE_ENV_DELETE_BLOCK_SET"
got = ENV.delete(present) { |missing| missing }
p got, got.frozen?, got.equal?(present)

# nil, a new String and another variable's String
p ENV.delete(present)
fresh = ENV.delete(present) { |missing| missing + "x" }
fresh << "y"
other = +"other"
picked = ENV.delete(present) { other }
picked << "!"
p present, fresh, other

# a conditional, a freeze and a bang answer the key itself too
maybe = ENV.delete(present) { |missing| missing.size > 3 ? missing : nil }
maybe << "?"
bang = ENV.delete(present) { |missing| missing.upcase! || missing }
bang << "."
p present
frozen = ENV.delete(+"SPINEL_SHARE_ENV_DELETE_BLOCK_FREEZE") { |missing| missing.freeze }
p frozen.frozen?

# a new key's String reaches the block alone
def new_key = +"SPINEL_SHARE_ENV_DELETE_BLOCK_NEW"
seen = nil
ENV.delete(new_key) { |missing| seen = missing }
seen << "!"
p seen

# the value handed on as an argument and an element
def bump(s) = s << "+"
bump(ENV.delete(present) { |missing| missing })
list = [ENV.delete(present) { |missing| missing }]
list[0] << "-"
p present, list
