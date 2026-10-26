# A block made from a Symbol a local holds (`m(&s)`, `m(&s.to_proc)`, and
# the lambda `s.to_proc`) sends the Symbol the local held where the block
# argument was evaluated, not whatever the local holds when the block runs.

def keep(&b) = (@b = b)

s = "upcase".to_sym
keep(&s)
s = :downcase
p @b.call("aB")

t = "upcase".to_sym
keep(&t.to_proc)
t = :downcase
p @b.call("aB")

# the lambda Symbol#to_proc answers
w = :upcase
pr = w.to_proc
w = :downcase
p pr.call("aB")

# a callee that yields again after a closure rewrote the local
def each2(f)
  a = yield("aB")
  f.call
  b = yield("cD")
  [a, b]
end
v = :upcase
p each2(-> { v = :downcase }, &v)

# run inline while the local changes between calls
u = :upcase
p ["aB", "cD"].map { |x| r = [x].map(&u)[0]; u = :downcase; r }

# made once per run of a block: each kept block keeps its own Symbol
@ks = []
def keep2(&b) = (@ks << b)
%w[upcase downcase].each { |n| m = n.to_sym; keep2(&m); m = :swapcase }
p @ks.map { |b| b.call("aB") }

# a comparator's two-parameter block, and a parameter
op = :+
p [1, 2, 3].reduce(&op)
def f(sym) = ["xY"].map(&sym)
p f(:upcase)
p f("down#{"case"}".to_sym)

# an operand ahead of `&s` that rebinds s: s is read in its turn, after it
def m1(a, &b) = [a, b.call("aB")]
w = :upcase
p m1((w = :downcase), &w)
def m3(a, b, &blk) = [a, b, blk.call("cD")]
x = :upcase
p m3(x, (x = :downcase), &x)
y = :upcase
p m3(y, [y = :swapcase][0], &y)
