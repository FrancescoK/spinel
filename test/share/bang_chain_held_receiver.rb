# A chain of bangs over a String a method answers (`id(s).upcase!.downcase!`)
# is held as the handle that method answers. The compiler asked each link
# whether it hands that handle on once for every path that reaches it, so
# compiling the chain took time exponential in its length; it is forty links
# here (make scale-test compiles this file under a CPU-time limit). Every
# link changes the String the method answered, which is s, so s and the name
# it shares with see each change.
def id(x) = x
s = +"ab"
t = s
t << "c"
a = [id(s).upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!, 1]
p a[0], s, t
b = id(s).upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!.downcase!.upcase!
p b, s.equal?(t)
