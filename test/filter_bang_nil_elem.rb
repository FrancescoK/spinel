# The in-place filters (select!, filter!, keep_if, reject!, delete_if) over
# an Integer or Float Array holding a nil keep that nil as nil when they keep
# it, and the slots the compaction cuts off (theirs and uniq!'s with a block)
# leave no nil behind for a later push to read.
a = [1, 2]
a[3] = 5
b = a.dup; p b.select! { |v| v.nil? || v > 1 }; p b
b = a.dup; p b.filter! { |v| v != 1 }; p b
b = a.dup; p b.keep_if { |v| v != 2 }; p b
b = a.dup; p b.reject! { |v| v == 1 }; p b
b = a.dup; p b.delete_if { |v| v == 2 }; p b
b = a.dup; p b.keep_if { |v| v }; p b
b = a.dup; b.select! { |v| v.nil? ? false : v < 3 }; b << 7; p b
b = a.dup; b.delete_if { |v| v == 5 }; b << 7; p b
b = a.dup; b.reject! { |v| break if v == 5; v == 1 }; p b
b = a.dup; b.select! { |v| break if v == 5; v != 1 }; b << 7; p b

f = [1.5, 2.5]
f[3] = 5.5
g = f.dup; p g.select! { |v| v.nil? || v > 2 }; p g
g = f.dup; p g.reject! { |v| v == 1.5 }; p g
g = f.dup; p g.delete_if { |v| v == 5.5 }; g << 7.5; p g

u = [3, 3, 1]
u[4] = 1
u.uniq! { |v| v }; u << 7; p u
h = [1.5, 1.5]
h[3] = 2.5
h.uniq! { |v| v }; p h

# a block parameter widened to poly (a second class defining the receiver's
# method name, plus a never-called caller chain)
class Box
  def bytes
  end
end

Spec = Struct.new(:includes)

def ints_of(pattern)
  a = pattern.bytes
  a[3] = 1
  b = a.dup; p b.select! { |v| v.nil? || v > 97 }; p b
  b = a.dup; p b.keep_if { |v| v != 97 }; p b
  b = a.dup; p b.reject! { |v| v == 97 }; p b
  b = a.dup; p b.delete_if { |v| v == 98 }; p b
  b = a.dup; b.delete_if { |v| v == 1 }; b << 7; p b
end

def walk(patterns)
  patterns.each { |pattern| ints_of(pattern) }
end

def sweep(specs)
  specs.each { |spec| walk(spec.includes) }
end

ints_of("ab")
