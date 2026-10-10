# The declaration covers the reads in the answer the map! block stores, not
# every read of the parameter: `last = x` wraps the bytes into a new String
# that is not the element (a wrong answer under --share-strings, whose
# report is what this records).
last = nil
r = " a ,b".split(",").map! { |x| last = x; x.strip! || x }
last << "!"
p r, last
