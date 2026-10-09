# A scan block over a receiver only known to be a String at run time, inside a
# yielding method that is inlined at its call: the inline renames the method's
# locals, and a block parameter that shares its name with one of them is bound
# under the renamed name. The parameter is a boxed value, so it is bound as one
# whichever name the lookup finds it by.
def run(boxed)
  bm = 0
  kept = []
  boxed.scan(/./) { |bm| kept << bm }
  yield kept, boxed, bm
end
run([+"abc", 1].first) { |k, b, x| p k, b, x }
run([+"xy", 1].first) { |k, b, x| p k, b, x }

# the same without the clash
def run2(boxed)
  q = 0
  kept = []
  boxed.scan(/./) { |bm| kept << bm }
  yield kept, boxed, q
end
run2([+"abc", 1].first) { |k, b, x| p k, b, x }

# the parameter is used inside the block as well as kept
def run3(boxed)
  bm = 0
  out = []
  boxed.scan(/./) { |bm| out << bm.upcase }
  yield out, bm
end
run3([+"abc", 1].first) { |o, x| p o, x }

# a clashing local in the same method keeps its own value
def run4(boxed)
  bm = 7
  n = 0
  boxed.scan(/./) { |bm| n += bm.size }
  yield n, bm
end
run4([+"abc", 1].first) { |n, x| p n, x }
