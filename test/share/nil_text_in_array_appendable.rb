# nil.inspect and an empty String#* are new Strings: an append through the
# Array that keeps one changes it (#9258)
r = []
r << nil.inspect
r << nil.to_s * 2
r << "" * 3
a = [r[0], r[1], r[2]]
a.each { |e| e << "!" }
p a
