# A loop that reads an Integer or Float Array in range by its own test
# (`i = 0; while i < a.length ... a[i] ... i += 1`) reads the element with no
# test of its own only where no nil can be in the array at run time. The nil
# mark is the array's, not a name's: a nil stored through another name of the
# same array -- a parameter, a local assigned from it, what a method or a
# block answered, an ivar it was handed to, a mixed slot that boxed it -- or a
# gap a write past the end left marks the array the loop reads too, or the
# loop read the nil as an Integer where CRuby raises. Each case reads through
# a method of its own, so no case's mark reaches another's reader.
H = {1 => 5}
HF = {1 => 5.0}

def run(name)
  p [name, yield]
rescue NoMethodError => e
  p [name, e.class]
end

def add(x, k) = x << H[k]
def add_twice(y, k) = add(y, k)
def add_at_end(x, k)
  x[x.length] = H[k]
end
def push_one(x, k) = x.push(H[k])
def addf(x, k) = x << HF[k]
def same(x) = x
def put(a, i)
  a[i] = 1
end

class Adder
  def go(a) = add(a, 7)
end

class Grower
  def initialize(a) = @a = a
  def grow = @a << H[7]
end

class Keeper
  def initialize = @a = [1, 2]
  def grow = @a << H[7]
  def a = @a
end

def add_mixed(v)
  v << H[7] if v.is_a?(Array)
end
add_mixed("s")

class MixedHolder
  def initialize(v) = @v = v
  def grow = (@v << H[7] if @v.is_a?(Array))
end
MixedHolder.new("s")

def answer = yield
def grow_answer
  x = yield
  x << H[7]
  x
end

def sum0(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case0
  a = [1, 2]
  add(a, 7)
  sum0(a)
end
run("parameter") { case0 }

def sum1(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case1
  a = [1, 2]
  add_twice(a, 7)
  sum1(a)
end
run("two calls") { case1 }

def sum2(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case2
  a = [1, 2]
  add_at_end(a, 7)
  sum2(a)
end
run("index write") { case2 }

def sum3(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case3
  a = [1, 2]
  push_one(a, 7)
  sum3(a)
end
run("push") { case3 }

def sum4(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case4
  a = [1, 2]
  Adder.new.go(a)
  sum4(a)
end
run("method of a class") { case4 }

def sum5(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case5
  a = [1, 2]
  b = a
  b << H[7]
  sum5(a)
end
run("local alias") { case5 }

def sum6(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case6
  a = [1, 2]
  b = same(a)
  b << H[7]
  sum6(a)
end
run("returned alias") { case6 }

def sum7(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case7
  a = [1, 2]
  Grower.new(a).grow
  sum7(a)
end
run("ivar it was handed to") { case7 }

def sum8(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case8
  k = Keeper.new
  k.grow
  a = k.a
  sum8(a)
end
run("ivar handed out") { case8 }

def sum9(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case9
  a = answer { b = [1, 2]; add(b, 7); b }
  sum9(a)
end
run("block's answer") { case9 }

def sum10(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case10
  a = [1, 2]
  grow_answer { a }
  sum10(a)
end
run("array a block answered") { case10 }

def sum11(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case11
  a = [1]
  put(a, 3)
  sum11(a)
end
run("gap left past the end") { case11 }

def sum12(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case12
  a = [1, 2]
  [a, "x"].each { |x| x << H[7] if x.is_a?(Array) }
  sum12(a)
end
run("boxed by a mixed literal") { case12 }

def sum13(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case13
  a = [1, 2]
  box = ["s"]
  box << a
  box.each { |x| x << H[7] if x.is_a?(Array) }
  sum13(a)
end
run("boxed by a push") { case13 }

def sum14(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case14
  a = [1, 2]
  v = ARGV.size > 5 ? "s" : a
  v << H[7] if v.is_a?(Array)
  sum14(a)
end
run("boxed by a mixed local") { case14 }

def sum15(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case15
  a = [1, 2]
  add_mixed(a)
  sum15(a)
end
run("boxed by a mixed parameter") { case15 }

def sum16(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case16
  a = [1, 2]
  h = {k: a, s: "x"}
  h.each_value { |x| x << H[7] if x.is_a?(Array) }
  sum16(a)
end
run("boxed by a Hash value") { case16 }

def sum17(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def case17
  a = [1, 2]
  MixedHolder.new(a).grow
  sum17(a)
end
run("boxed by a mixed ivar") { case17 }

# the block whose answer carries the nil is one of more than 64 a method
# yields to: every block's tail is asked, not the first 64
def give = yield
def many_sum(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
give { [0] }
give { [1] }
give { [2] }
give { [3] }
give { [4] }
give { [5] }
give { [6] }
give { [7] }
give { [8] }
give { [9] }
give { [10] }
give { [11] }
give { [12] }
give { [13] }
give { [14] }
give { [15] }
give { [16] }
give { [17] }
give { [18] }
give { [19] }
give { [20] }
give { [21] }
give { [22] }
give { [23] }
give { [24] }
give { [25] }
give { [26] }
give { [27] }
give { [28] }
give { [29] }
give { [30] }
give { [31] }
give { [32] }
give { [33] }
give { [34] }
give { [35] }
give { [36] }
give { [37] }
give { [38] }
give { [39] }
give { [40] }
give { [41] }
give { [42] }
give { [43] }
give { [44] }
give { [45] }
give { [46] }
give { [47] }
give { [48] }
give { [49] }
give { [50] }
give { [51] }
give { [52] }
give { [53] }
give { [54] }
give { [55] }
give { [56] }
give { [57] }
give { [58] }
give { [59] }
give { [60] }
give { [61] }
give { [62] }
give { [63] }
give { [64] }
give { [65] }
give { [66] }
give { [67] }
give { [68] }
def many_case
  a = give { b = [1, 2]; add(b, 7); b }
  many_sum(a)
end
run("one of many blocks") { many_case }

def fsum(fl)
  s = 0.0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
def fcase
  a = [1.0, 2.0]
  addf(a, 7)
  fsum(a)
end
run("Float parameter") { fcase }

# an array the nil never reaches keeps its answer
def usum(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 3
    e += 1
  end
  s
end
run("untouched") { usum([4, 5, 6]) }
