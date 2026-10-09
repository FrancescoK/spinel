# concat with several arguments answers its receiver, as a bang method that
# changed it does, and no alias walk follows the call. The retained result
# is a copy today, so an append through it would not reach s (CRuby
# "abxy!", Spinel "abxy"): refused, as `r = s.strip!` is.
s = +"ab"
r = s.concat("x", "y")
r << "!"
p s
