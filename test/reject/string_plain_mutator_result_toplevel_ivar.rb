# A top-level instance variable that keeps the result of concat with several
# arguments holds a copy of the receiver's String, as a local or a global
# does, so an append through it would not reach @s (CRuby "abxy!", Spinel
# "abxy"): refused, as `@r = @s.strip!` is.
@s = +"ab"
@r = @s.concat("x", "y")
@r << "!"
p @s
