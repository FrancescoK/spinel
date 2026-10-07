# Refused without --share-strings, as before: a String variable stored into
# a Struct member by a multiple assignment with a key that is no literal,
# on a receiver typed as the Struct, would be a copy in the member, and the
# append through the member would not reach the variable (CRuby: "q!").
# Under --share-strings the member holds the String's handle.
S = Struct.new(:x, :y)
k = ARGV.size
t = S.new(+"a", 1)
s = +"q"
t[k], t[k + 1] = s, 3
t.x << "!"
p s, t
