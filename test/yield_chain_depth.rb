# A block that yields on to the block of the method it is written in
# reaches that block however many inlined methods deep the chain is. The
# inliner recorded the block one level out only, so in a chain three
# methods deep the middle block's own yield found no block at all and
# raised LocalJumpError; a block forwarded by name (`run(x, &b)`) was its
# own target and did the same at two levels, and so did a chain spliced
# inside a lowered (recursive) yielding method. Appends are LONG, which
# always reallocates.

LONG = "!" * 100

def run(x) = yield(x)
def run2(x) = run(x) { |u| yield u }
def run3(x) = run2(x) { |v| yield v }
def run4(x) = run3(x) { |t| yield t }
run3(1) { |w| p w }
p(run3(2) { |w| w * 10 })
p(run4(3) { |w| w + 1 })

# the String the outermost block appends to is the caller's
def srun(x) = yield(x)
def srun2(x) = srun(x) { |u| yield u }
def srun3(x) = srun2(x) { |v| yield v }
def srun4(x) = srun3(x) { |t| yield t }
s3 = +"a"; srun3(s3) { |w| w << LONG }; p s3.size
s4 = +"b"; srun4(s4) { |w| w << LONG }; p s4.size

# each level's block runs under the self it is written in
class A
  def run(x) = yield(x)
end
class B
  def initialize = (@n = "B"; @a = A.new)
  def run2(x) = @a.run(x) { |u| yield u, @n }
end
class C
  def initialize = (@n = "C"; @b = B.new)
  def tag = "t"
  def run3(x) = @b.run2(x) { |v, n| yield v, n + @n + tag }
end
class D
  def initialize = (@n = "D")
  def go
    C.new.run3(1) { |w, n| p [w, n, @n] }
    p(C.new.run3(2) { |w, n| break w * 100 if w > 1; 0 })
    p(C.new.run3(3) { |w, n| next w + 1 })
  end
end
D.new.go

# a block forwarded by name, and a chain inside a recursive yielding method
def frun2(x, &b) = run(x, &b)
def frun3(x) = frun2(x) { |v| yield v + 1 }
frun3(1) { |w| p w }
def lrun(x) = yield(x)
def lrun2(x) = lrun(x) { |u| yield u }
def rec(n)
  return lrun2(n) { |v| yield v + 1 } if n == 0
  rec(n - 1) { |z| yield z * 2 }
end
rec(2) { |w| p w }
