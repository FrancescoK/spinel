# A Bignum element is an Integer to grep, all? and none?, as a Fixnum
# element is.
a = [2**70, 1, "s"]
p a.grep(Integer)
p a.all?(Integer)
p [2**70, 3].all?(Integer)
p [-(2**64), 2**70].none?(Integer)
p a.grep(Numeric).size
p [2**70, "s"].grep_v(Integer)
x = [2**70, "s"][0]
p x.is_a?(Integer)
