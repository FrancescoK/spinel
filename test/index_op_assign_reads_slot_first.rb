# `recv[key] OP= rhs` evaluates the receiver, then the key, then reads the
# slot, and only then runs the right-hand side. `||=` / `&&=` run the
# right-hand side only when the slot calls for the write.

$log = []

def idx
  $log << :idx
  0
end

def na(a)
  $log << :na
  a[0] = [9]
  3
end

a = [[1]]
a[0] |= [na(a)]
p a
a = [[1]]
a[0] += [na(a)]
p a
a = [[1, 3]]
a[0] -= [na(a)]
p a
$log = []
a = [[1]]
a[idx] |= [na(a)]
p a, $log
x = [[1]]
v = (x[0] |= [na(x)])
p v, x

$log = []
a = [[1]]
a[0] ||= [na(a)]
p a, $log
a = [nil]
a[0] ||= [na(a)]
p a
a = [[1]]
a[0] &&= [na(a)]
p a

def ni(a)
  $log << :ni
  a[0] = 100
  [1, 2]
end

a = [10]
a[0] += [ni(a)].size
p a
a = [10]
a[0] <<= [ni(a)].size
p a
a = [10]
v = (a[0] += [ni(a)].size)
p v, a
$log = []
a = [10]
v = (a[0] ||= [ni(a)].size)
p v, a, $log

def nf(a)
  a[0] = 9.5
  [1]
end
fl = [1.5]
fl[0] += [nf(fl)].size
p fl

def ns(a)
  a[0] = "zz"
  "c"
end
sa = ["ab"]
sa[0] += [ns(sa)].first
p sa
sa = ["ab"]
sa[0] *= [ns(sa)].size + 1
p sa

def nh(h)
  $log << :nh
  h["k"] = 50
  [1, 2]
end
h = {"k" => 1}
h["k"] += [nh(h)].size
p h
h = {"k" => 1}
v = (h["k"] += [nh(h)].size)
p v, h
$log = []
h = {"k" => 1}
h["k"] ||= [nh(h)].size
p h, $log
h = {"k" => [1]}
def nha(h)
  h["k"] = [9]
  3
end
h["k"] += [nha(h)]
p h
h = {"k" => [1]}
h["k"] ||= [nha(h)]
p h

class Box
  def initialize
    @a = [[1]]
    @h = {k: [1]}
  end

  def run
    @a[0] |= [swap]
    @h[:k] += [store]
    [@a, @h]
  end

  def swap
    @a = [[7]]
    3
  end

  def store
    @h[:k] = [8]
    4
  end
end
p Box.new.run

def nz(x)
  x[:k] = 70
  1
end
def poly_hash(x)
  x[:k] += [nz(x)].size
  x
end
p poly_hash({k: 1})
p poly_hash({k: 1.5})

def npa(a)
  a[0] = 40
  1
end
pa = [1, "s"]
pa[0] += [npa(pa)].size
p pa
pa = [1, "s"]
pa[0] ||= [npa(pa)].size
p pa
