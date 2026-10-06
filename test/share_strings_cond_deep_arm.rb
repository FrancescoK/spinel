# A conditional value stored into a String variable that holds a shared
# handle is stored arm by arm. An arm nested deeper than the arm walk goes
# (each pair of parentheses counts) is stored as a value of its own, its
# effects run: it was read as nil. Only conditionals count toward that
# depth, not the parentheses around an arm. An ivar's write beside a raise
# arm is stored as its String. Run with and without --share-strings.
c = ARGV.empty?; d = !c
t = +"q"; t << ""
t = c ? (d ? (@r = +"r") : (@s = +"s")) : +"n2"
p @s, t
s = +"s"; u = s; s << "!"
u = c ? (d ? (s) : (+"deep")) : +"n"
p u
w = s; s << "?"
w = c ? (!d ? (s) : (+"x")) : +"n"
s << "1"
p w, s
v = +"v"; v << ""; y = +"y"; y << ""
y = c ? (case 1 when 1 then (c ? (d || (v)) : +"z") end) : +"n"
p y.equal?(v)
q = +"q"; q << ""; q = c ? (@r = +"r") : (raise "boom")
p q
