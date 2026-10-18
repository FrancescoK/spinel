# A local bound from an element read of an Array literal is the String
# variable the literal holds, so a change through it changes s in CRuby.
# The local holds a copy and s stayed "xy": refused rather than compiled
# wrong.
s = +"xy"
t = [s][0]
t.prepend("q")
p s
