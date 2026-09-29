# A String Range held boxed (in an array, a hash, a poly slot) prints and
# inspects as the typed one does.
p ["a".."c", 1]
p ["a"..."c", 1]
x = ["b".."d", :s]
puts x[0]
puts "#{x[0]}"
p x[0].to_s, x[0].inspect
h = {r: "a".."z", n: 2}
p h
puts h[:r]
p [1.5..2.5, 1]
p [(1..2), "x"]
