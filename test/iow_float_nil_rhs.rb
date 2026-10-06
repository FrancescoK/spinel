# `a[i] OP= v` on a Float array raises TypeError when v is nil (an element
# past the end or in a gap, a Float or an Integer that may be nil), as
# `a[i] + v` does: the C operator stored the nil's NaN payload, or the
# Integer sentinel as a number. A nil element raises NoMethodError first. In
# a loop whose array headers are cached, a Float local on the right is tested
# through the cached nil-free length, so an element below it pays no test.
def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def elem(z, e, i)
  z[0] += e[i]
  z
end

def float_local(z, k)
  x = 2.5 if k > 0
  z[0] += x
  z
end

def int_local(z, s)
  x = s.index("b")
  z[0] *= x
  z
end

def looped(z, e, n)
  j = 0
  while j < n
    z[0] += e[j]
    j += 1
  end
  z
end

def looped_sub(z, e, n)
  j = 0
  while j < n
    z[j] -= e[j]
    j += 1
  end
  z
end

def loop_local(z, k, n)
  r = 2.5 if k > 0
  j = 0
  while j < n
    z[j] += r
    j += 1
  end
  z
end

def shared(z, k, n, add)
  r = 2.5 if k > 0
  s = 0.0
  j = 0
  while j < n
    z[j] += r if add
    s += z[j]
    j += 1
  end
  s
end

def gap
  e = Array.new(1, 1.5)
  e[2] = 3.0
  e
end

show("past the end") { elem([0.0], [1.5], 3) }
show("in a gap") { elem([0.0], gap, 1) }
show("float local nil") { float_local([0.0], 0) }
show("int local nil") { int_local([1.0], "xyz") }
show("element nil first") { elem(gap.rotate(1), [1.5], 3) }
show("loop past the end") { looped([0.0], [1.5], 2) }
show("loop in a gap") { looped([0.0], gap, 2) }
show("loop, both nil") { looped_sub(gap, Array.new(1, 0.5), 2) }
show("loop, element nil") { looped_sub(gap, Array.new(2, 0.5), 2) }
show("loop past the end, element not nil") { looped_sub(Array.new(2, 1.0), Array.new(1, 0.5), 2) }
show("loop, local nil") { loop_local(Array.new(2, 1.0), 0, 2) }
show("loop, local nil, element nil") { loop_local(gap, 0, 2) }
show("loop, local") { loop_local(Array.new(2, 1.0), 1, 2) }
show("loop, local nil, not added") { shared(Array.new(2, 1.0), 0, 2, false) }
show("loop, local, added") { shared(Array.new(2, 1.0), 1, 2, true) }
show("ok") { [elem([1.0], [1.5], 0), float_local([1.0], 1), int_local([1.5], "abc"), looped([0.0], [1.5, 2.5], 2), looped_sub(Array.new(2, 1.0), Array.new(2, 0.5), 2)] }
