# A split's each in an expression whose rescue modifier retries: the retry
# runs the each again over the same Strings. The Strings are shared now
# (#6765); what is still refused is the retry in a rescue modifier, which
# Spinel does not take outside a rescue clause.
out = []
a = "a;b".split(";")
i = 0
(a.each { |x| x << "!"; out << x }; i += 1; raise "again" if i < 2) rescue retry
p out
