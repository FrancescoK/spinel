# A Hash.new block is handed the key a read asks for, here s itself, so
# its append changes s. It appended to a copy and s stayed "abc": refused,
# not compiled wrong.
h = Hash.new { |hh, k| k << "!" }
s = +"abc"
h[s]
p s
