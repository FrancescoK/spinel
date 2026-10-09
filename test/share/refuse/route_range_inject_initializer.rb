# spinel: not-cruby
# Returning the memo retains the initializer. The result route cannot yet
# carry its shared handle and must be refused instead of copying it.
s = +"a"
r = (1..2).inject(s) { |memo, i| memo }
r << "!"
p [s, r]
