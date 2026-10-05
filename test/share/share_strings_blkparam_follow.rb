# Flag-only: without the flag (as on master) this program is refused.
# A block passed to a method whose &b it only calls binds what the calls
# hand it, as a yield's block does: a String it appends to is the caller's.
def each_word(words, &b)
  words.each { |w| b.call(w) }
  b.call(+"tail") if b
end
def twice(x, &b) = (b.(x); b[x]; b)
def visit(s, &blk) = blk.call(s, s.size)
out = +""
seen = []
each_word([+"a", +"b"]) { |w| w << "!"; seen << w }
p seen
s = +"s"
twice(s) { |x| x << "+" }
p s
r = visit(+"q") { |t, n| t << n.to_s; t }
p r
kept = []
each_word([+"k"]) { |w| kept << w }
kept.each { |w| w << "?" }
p kept
def keep(&b) = (@saved = b; nil)
keep { |z| z << "x" }
v = +"v"
@saved.call(v)
p v
