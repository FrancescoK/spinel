# A mutator on a boxed String read back out of a container (an Array
# literal, an ivar's or a global's Array, a nested literal, an iterator's
# element) changes the String itself, which every name for it sees.
k = ARGV.size
s = [+"xy", 1][k]
[s][0].prepend("q")
p s
s = [+"xy", 1][k]
[s][0].insert(0, "<")
[s][0].concat(">", "!")
p s
s = [+"xy", 1][k]
a = [s, 2]
a[0].prepend("^")
a[0] << "$"
p s, a
def mk(s) = [s, 1]
s = [+"xy", 1][k]
b = mk(s)
b[0].prepend("q")
b[0].insert(1, "-")
b.first.concat("!", "?")
p s, b
s = [+"xy", 1][k]
@a = []
@a << s
@a[0].prepend("q")
$g = [s, :x]
$g[0].concat("!")
p s, @a, $g
s = [+"xy", 1][k]
t = [[s]][0][0]
t.prepend("q")
[s].each { |e| e.insert(0, "<") }
[s].map { |e| e.concat(">") }
p s
