# A split's each in an expression whose rescue modifier retries: the retry
# runs the each again over the same Strings. Still refused, not silently
# applied to copies.
# spinel: reject-thread-string
out = []
a = "a;b".split(";")
i = 0
(a.each { |x| x << "!"; out << x }; i += 1; raise "again" if i < 2) rescue retry
p out
