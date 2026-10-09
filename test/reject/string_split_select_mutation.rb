# spinel: reject-share
# select answers some of the very Strings its block mutated in place, so
# the mutation is read back through its answer: refused, not silently
# applied to a copy.
# spinel: reject-thread-string
p " a , b ".split(",").select { |x| x.strip!; true }
