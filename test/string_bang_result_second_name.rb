# t is a second name for s, so the bang method's result is s itself. The
# retained result is a copy today, and an append through it would not
# reach s (CRuby "ab!", Spinel "ab"): refused, as `r = s.strip!` is,
# though t itself is not read again.
s = +"ab "
t = s
r = t.strip!
r << "!"
p s
