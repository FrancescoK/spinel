# map! / collect! over an Integer or Float Array holding a nil bind the nil
# element as nil to a block parameter that can hold it.
a = [1, 2]
a[3] = 5
b = a.dup; p b.map! { |v| v }; p b
b = a.dup; p b.map! { |v| v.nil? ? 0 : v * 2 }
b = a.dup; p b.collect! { |v| v || 9 }
b = a.dup; p b.map! { |v| v.nil? ? -1 : v }.sum

f = [1.5]
f[2] = 2.5
g = f.dup; p g.map! { |v| v }
g = f.dup; p g.map! { |v| v.nil? ? 0.0 : v * 2 }
