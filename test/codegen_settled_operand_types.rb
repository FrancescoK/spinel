# Shapes that read a node's settled type in codegen where it used to
# re-infer it, and that nothing else in the corpus reaches: a String
# range's membership test with a boxed operand, <=> on a desugared
# `:sym.to_s` against a boxed operand, and a String handle yielded into
# a proc (its read marked as the handle for that call alone).

def pick(i) = i == 0 ? 1 : "c"

r = ("a".."e")
x = pick(ARGV.size + 1)
p r.include?(x)
p r.cover?(x)
p r.include?(pick(0))
p :abc.to_s <=> x
s = :abc
p s.to_s <=> pick(0)

def each_word
  w = +"ab"
  w << "c"
  yield w
  yield w.dup
  w
end

def run(&blk)
  each_word(&blk)
end

out = []
pr = proc { |w| w << "!"; out << w }
p run(&pr)
p out
p each_word(&lambda { |w| w.upcase! })
