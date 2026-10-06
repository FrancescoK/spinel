# An index that may be nil, used in a loop whose array headers are cached
# (emit_while), raises TypeError when it is nil, on a read, a write and a
# Float operand read nil-free, and reads and writes as before otherwise.
# The nil test runs where the bounds compare sends a nil index (the -2^63
# sentinel fails it), not on every in-range access.
def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def read_at(a, s, n)
  k = s.index("b")
  t = 0
  j = 0
  while j < n
    t += a[k]
    j += 1
  end
  t
end

def write_at(a, s, n)
  k = s.index("b")
  j = 0
  while j < n
    a[k] = j
    j += 1
  end
  a
end

def float_at(f, s, n)
  k = s.index("b")
  t = 0.0
  j = 0
  while j < n
    t += f[k]
    j += 1
  end
  t
end

show("read") { read_at([10, 20, 30], "abc", 3) }
show("read nil") { read_at([10, 20, 30], "xyz", 3) }
show("read nil, no pass") { read_at([10, 20, 30], "xyz", 0) }
show("read past the end") { read_at([10], "abc", 2) }
show("write") { write_at([0, 0, 0], "abc", 3) }
show("write nil") { write_at([0, 0, 0], "xyz", 3) }
show("write past the end") { write_at([0], "abc", 2) }
show("float") { float_at([0.5, 1.5], "abc", 2) }
show("float nil") { float_at([0.5, 1.5], "xyz", 2) }
show("float past the end") { float_at([0.5], "abc", 1) }
