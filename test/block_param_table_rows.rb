# A table's rows spread into a block (`table.each { |row| yield(*row) }`)
# bind the elements' type, once the table's rows are typed after the
# fixpoint: Integer and Float rows bind unboxed parameters, a short row
# leaves the rest nil, and a table of mixed rows stays boxed. A local
# assigned an array literal once and never changed spreads every element
# it was given, so its parameters hold no nil; one that is pushed onto,
# handed to a method, aliased or assigned under a condition spreads what
# the run time finds.

def each_row(table)
  table.each { |row| yield(*row) }
end

ints = Array.new(4) { |i| [i, i + 1, i + 2] }
t = 0
each_row(ints) { |a, b, c| t += a + b * c }
p t
each_row(ints) { |a, b, c| p [a, b, c] }

# short rows: the parameters a row does not reach are nil
short = [[1, 2, 3], [4, 5], [6]]
each_row(short) { |sa, sb, sc| p [sa, sb, sc, sb.nil?, sc.nil?] }
each_row(short) { |sa, sb, sc| p(sc ? sa + sb * sc : sa) }
each_row(short) do |sa, sb, sc|
  begin
    p sa + sb * sc
  rescue NoMethodError, TypeError => e
    p e.class
  end
end
each_row(short) { |sa, sb, sc| p "#{sa}-#{sb}-#{sc}" }

def each_frow(table)
  table.each { |row| yield(*row) }
end
floats = Array.new(3) { |i| [i * 0.5, i + 0.25] }
s = 0.0
each_frow(floats) { |fx, fy| s += fx * fy }
p s
fshort = [[1.5], [2.5, 0.5]]
each_frow(fshort) { |gx, gy| p [gx, gy, gy.nil?] }

# a table of Integer and Float rows stays boxed
def each_mrow(table)
  table.each { |row| yield(*row) }
end
mixed = [[1, 2], [1.5, 2.5], [3, 4]]
each_mrow(mixed) { |ma, mb| p [ma, mb, ma * mb] }
each_mrow([[1, 2.5], [3, 4]]) { |na, nb| p na + nb }

# rows mutated inside the loop
def each_grown(table)
  table.each do |row|
    row << row.sum
    yield(*row)
  end
end
grow = Array.new(3) { |i| [i, i * 2] }
each_grown(grow) { |ga, gb, gc| p [ga, gb, gc] }
p grow
def each_hrow(table)
  table.each { |row| yield(*row) }
end
each_hrow(grow) { |ha, hb, hc, hd| p [ha, hb, hc, hd] }
def each_krow(table)
  table.each { |row| yield(*row) }
end
shrink = [[1, 2, 3], [4, 5, 6]]
each_krow(shrink) { |ka, kb, kc| shrink[1].pop; shrink[0][1] = 7; p [ka, kb, kc] }
p shrink[0], shrink[1]

# a literal local no one changes: every element is there
def sure_pair(n)
  pair = [3, 4]
  i = 0
  while i < n
    yield(*pair)
    i += 1
  end
end
u = 0
sure_pair(5) { |pa, pb| u += pa * pb }
p u
sure_pair(1) { |qa, qb| p [qa, qb, qb.nil?] }
sure_pair(1) { |ra, rb, rc| p [ra, rb, rc, rc.nil?] }
def sure_floats
  xs = [1.5, 0.25]
  yield(*xs)
  yield(*xs, 9.0)
end
sure_floats { |sx, sy, sz| p [sx, sy, sz] }
def sure_index
  pair = [7, 8]
  p pair[0] + pair[1]
  yield(*pair)
end
sure_index { |ia, ib| p ia * ib }

# a literal local that changes, or may not have run: what the run time finds
def pushed
  pair = [3, 4]
  pair << 5
  yield(*pair)
  pair.pop
  pair.pop
  yield(*pair)
end
pushed { |ua, ub, uc| p [ua, ub, uc] }
def grow_arg(xs) = xs << 6
def handed
  pair = [3, 4]
  grow_arg(pair)
  yield(*pair)
end
handed { |va, vb, vc| p [va, vb, vc] }
def aliased
  pair = [3]
  other = pair
  other << 4
  yield(*pair)
end
aliased { |wa, wb| p [wa, wb, wb.nil?] }
def maybe(flag)
  pair = [3, 4] if flag
  yield(*pair)
end
maybe(true) { |ya, yb| p [ya, yb] }
maybe(false) { |za, zb| p [za, zb, za.nil?] }
def cleared
  pair = [3, 4]
  cl = -> { pair.clear }
  cl.call
  yield(*pair)
end
cleared { |ca, cb| p [ca, cb] }
def reassigned
  pair = [3, 4]
  pair = [5] if pair.size > 5
  yield(*pair)
end
reassigned { |ea, eb| p [ea, eb] }
