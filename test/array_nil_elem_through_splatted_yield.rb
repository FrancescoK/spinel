# A block parameter bound by a yield's argument is another name of that
# argument's array, so a nil stored through it reaches a loop that reads the
# array in range (`i = 0; while i < a.length ... a[i] ... i += 1`). Past a
# splatted argument (`yield(*xs, a)`) the parameter can be bound to any of
# the arguments from the splat on, or to an element of the splatted array;
# where that element can itself be an array, the proof gives up and every
# such loop tests its elements. Each case reads through a method of its own.
H = {1 => 5}

def run(name)
  p [name, yield]
rescue NoMethodError => e
  p [name, e.class]
end

def give_after_empty(a)
  pre = []
  yield(*pre, a)
end
def give_splatted(a, b) = yield(*[a], b)

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
  a = [1, 2]
  give_after_empty(a) { |m| m << H[7] }
  sum0(a)
end
run("past an empty splat") { case0 }

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
  a = [1, 2]
  b = [3, 4]
  give_splatted(a, b) { |m, n| m << H[7] }
  sum1(a)
end
run("an element of the splatted array") { case1 }

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
run("untouched") { usum([4, 5, 6]) }
