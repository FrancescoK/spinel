# A nil (or a gap a write past the end left) stored into an Integer Array
# through another name of it reaches the loop that reads it in range
# (`i = 0; while i < a.length ... a[i] ... i += 1`), which must then test
# the element. The other name here is one a builtin hands back -- the value
# of a call whose row answers its receiver (`b = a.each { }`, `a.sort!`), of
# `then` (its block's value), of each_with_object (its memo) -- or a block
# parameter that is the receiver (`a.tap { |x| }`), the memo, or the argument
# a method's `yield` passes, or a box a `yield`'s value went into. Each case
# reads through a method of its own, so no case's mark reaches another's.
H = {1 => 5}

def run(name)
  p [name, yield]
rescue NoMethodError => e
  p [name, e.class]
end

def give(a) = yield(a)

class Box
  def initialize(a) = @a = a
  def each_arr = yield(@a)
end

class Keeper
  attr_reader :got
  def each = (@got = yield)
end

def sum0(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case0
  a = [1, 2, 3]
  b = a.each { |s| }
  b[5] = 9
  sum0(a)
end
run('each') { case0 }

def sum1(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case1
  a = [1, 2, 3]
  b = a.each_slice(2) { |s| }
  b[5] = 9
  sum1(a)
end
run('each_slice') { case1 }

def sum2(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case2
  a = [1, 2, 3]
  b = a.each_with_index { |s, j| }
  b[5] = 9
  sum2(a)
end
run('each_with_index') { case2 }

def sum3(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case3
  a = [1, 2, 3]
  b = a.reverse_each { |s| }
  b << H[7]
  sum3(a)
end
run('reverse_each') { case3 }

def sum4(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case4
  a = [1, 2, 3]
  b = a.tap { |s| }
  b[5] = 9
  sum4(a)
end
run('tap') { case4 }

def sum5(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case5
  a = [1, 2, 3]
  b = a.then { |x| x }
  b << H[7]
  sum5(a)
end
run('then') { case5 }

def sum6(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case6
  a = [2, 1, 3]
  b = a.sort!
  b[5] = 9
  sum6(a)
end
run('sort!') { case6 }

def sum7(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case7
  a = [1, 2, 3]
  b = a.map! { |x| x }
  b[5] = 9
  sum7(a)
end
run('map!') { case7 }

def sum8(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case8
  a = [1, 2, 3]
  b = a.rotate!
  b << H[7]
  sum8(a)
end
run('rotate!') { case8 }

def sum9(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case9
  a = [1, 2, 3]
  b = a.shuffle!(random: Random.new(1))
  b[5] = 9
  sum9(a)
end
run('shuffle! with a keyword') { case9 }

def sum10(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case10
  a = [1, 2, 3]
  b = a.keep_if { |x| true }
  b[5] = 9
  sum10(a)
end
run('keep_if') { case10 }

def sum11(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case11
  a = [1, 2, 3]
  b = a.replace([4, 5, 6])
  b << H[7]
  sum11(a)
end
run('replace') { case11 }

def sum12(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case12
  a = [1, 2]
  b = [1].each_with_object(a) { |e, m| }
  b << H[7]
  sum12(a)
end
run('each_with_object answer') { case12 }

def sum13(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case13
  a = [1, 2]
  a.tap { |x| x[4] = 1 }
  sum13(a)
end
run('tap parameter') { case13 }

def sum14(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case14
  a = [1, 2]
  a.then { |x| x << H[7] }
  sum14(a)
end
run('then parameter') { case14 }

def sum15(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case15
  a = [1, 2]
  [1].each_with_object(a) { |e, m| m << H[7] }
  sum15(a)
end
run('each_with_object memo') { case15 }

def sum16(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case16
  a = [1, 2]
  [1].inject(a) { |m, e| m << H[7]; m }
  sum16(a)
end
run('inject memo') { case16 }

def sum17(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case17
  a = [1, 2]
  give(a) { |m| m << H[7] }
  sum17(a)
end
run("a yield's argument") { case17 }

def sum18(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case18
  a = [1, 2]
  Box.new(a).each_arr { |m| m[4] = 1 }
  sum18(a)
end
run("a yield's ivar, boxed") { case18 }

def rec(a, d)
  if d > 0
    rec(a, d - 1) { |m| m << H[7] }
  else
    yield a
  end
end
give([0]) { |m| }
give([1]) { |m| }
give([2]) { |m| }
give([3]) { |m| }
give([4]) { |m| }
give([5]) { |m| }
give([6]) { |m| }
give([7]) { |m| }
give([8]) { |m| }
give([9]) { |m| }
give([10]) { |m| }
give([11]) { |m| }
give([12]) { |m| }
give([13]) { |m| }
give([14]) { |m| }
give([15]) { |m| }
give([16]) { |m| }
give([17]) { |m| }
give([18]) { |m| }
give([19]) { |m| }
give([20]) { |m| }
give([21]) { |m| }
give([22]) { |m| }
give([23]) { |m| }
give([24]) { |m| }
give([25]) { |m| }
give([26]) { |m| }
give([27]) { |m| }
give([28]) { |m| }
give([29]) { |m| }
give([30]) { |m| }
give([31]) { |m| }
give([32]) { |m| }
give([33]) { |m| }
give([34]) { |m| }
give([35]) { |m| }
give([36]) { |m| }
give([37]) { |m| }
give([38]) { |m| }
give([39]) { |m| }
give([40]) { |m| }
give([41]) { |m| }
give([42]) { |m| }
give([43]) { |m| }
give([44]) { |m| }
give([45]) { |m| }
give([46]) { |m| }
give([47]) { |m| }
give([48]) { |m| }
give([49]) { |m| }
give([50]) { |m| }
give([51]) { |m| }
give([52]) { |m| }
give([53]) { |m| }
give([54]) { |m| }
give([55]) { |m| }
give([56]) { |m| }
give([57]) { |m| }
give([58]) { |m| }
give([59]) { |m| }
give([60]) { |m| }
give([61]) { |m| }
give([62]) { |m| }
give([63]) { |m| }
give([64]) { |m| }
give([65]) { |m| }
give([66]) { |m| }
give([67]) { |m| }
give([68]) { |m| }
give([69]) { |m| }

def sum100(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case100
  a = [1, 2]
  b = [1].each { break a }
  b << H[7]
  sum100(a)
end
run("a break's value") { case100 }

def sum101(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case101
  a = [1, 2]
  b = a.then { |x| next x if x.size > 0; [7] }
  b << H[7]
  sum101(a)
end
run('then with a next') { case101 }

def sum102(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case102
  a = [1, 2]
  b = a.then do |x|
    x
  rescue ArgumentError
    x
  end
  b << H[7]
  sum102(a)
end
run('then with a rescue') { case102 }

def sum103(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case103
  a = [1, 2]
  rec(a, 1) { |m| }
  sum103(a)
end
run("a recursive call's block") { case103 }

def sum104(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case104
  a = [1, 2]
  give(a) { |m| m << H[7] }
  sum104(a)
end
run('one of many yield sites') { case104 }

def give9(a) = yield(1, 2, 3, 4, 5, 6, 7, 8, a)
def sum106(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case106
  a = [1, 2]
  give9(a) { |p1, p2, p3, p4, p5, p6, p7, p8, m| m << H[7] }
  sum106(a)
end
run("a yield's ninth argument") { case106 }

def give_splat(a) = yield(*Array.new(0, 0), a)
def sum107(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
def case107
  a = [1, 2]
  give_splat(a) { |m| m << H[7] }
  sum107(a)
end
run("a yield's argument past a splat") { case107 }

# a block's array a method keeps in an ivar, written through the ivar's reader
def ksum(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
class Rows
  def initialize = (@rows = [3, 1, 2])
  def leak(k) = k.each { @rows }
  def total = ksum(@rows)
end
def kcase
  r = Rows.new
  k = Keeper.new
  r.leak(k)
  k.got[4] = 9
  r.total
end
run("a block's array kept by its method") { kcase }

# an array the nil never reaches keeps its answer
def usum(fl)
  s = 0
  e = 0
  while e < fl.length
    s += fl[e] * 2
    e += 1
  end
  s
end
run("untouched") { usum([4, 5, 6].each { |x| }) }
