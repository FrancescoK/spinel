# spinel: gc-stress
# The two ends of a String Range, each made on the spot, are made in the
# order written, and the first is kept while the second is made.
def lo
  puts "lo"
  "b"
end

def hi
  puts "hi"
  "d"
end

def made(a, b)
  (a.to_s.."#{b}")
end

def covers(r, s)
  r.cover?(s)
end

def with_range(r)
  yield r
end

def pick(n, k)
  t = n.to_s + ""
  u = "j" + t
  k == 0 ? t : 1
end

p (lo..hi).to_a
r = (lo...hi)
p r.to_a
p (lo.dup..hi.dup).include?("c")

# a collection between the two ends takes neither
bad = 0
3000.times do |i|
  b = i.to_s
  e = (i + 3).to_s
  m = (i.to_s..(i + 3).to_s).max
  bad += 1 if m != (b > e ? nil : e)
end
p bad

none = 0
3000.times do |j|
  i = j + 100000
  none += 1 if (i.to_s...(i + 3).to_s).min.nil?
end
p none

i = 41
p ("k#{i}".."k#{i + 2}").to_a
x = "ab"
p (x.dup..x.succ).to_a
p (x.dup..).first

# a Range written in place is kept while a membership call makes its argument
ins = 0
outs = 0
120.times do |i|
  a = 100 + i
  b = 102 + i
  sa = "k" + a.to_s
  ins += 1 if (a.to_s..b.to_s).cover?((a + 1).to_s)
  ins += 1 if (a.to_s.."#{b}").include?((a + 1).to_s)
  ins += 1 if ("#{a}"..b.to_s).member?((a + 1).to_s)
  ins += 1 if (a.to_s.."#{b}") === (a + 1).to_s
  outs += 1 if (a.to_s..b.to_s).cover?(sa.succ)
  outs += 1 if (a.to_s.."#{b}").include?(sa.succ)
  outs += 1 if ("#{a}"..b.to_s).member?(sa.succ)
  outs += 1 if (a.to_s.."#{b}") === sa.succ
end
p ins, outs

# and wherever else no name holds it: a method's value, one of two arms, an
# argument, an end that is a String appended to, beside an argument that is
# a String or not, or beside another Range it is compared with
ins = 0
outs = 0
120.times do |i|
  a = 100 + i
  b = 102 + i
  sa = "k" + a.to_s
  buf = +""
  buf << a.to_s
  ins += 1 if made(a, b).cover?((a + 1).to_s)
  ins += 1 if (i.odd? ? (a.to_s..b.to_s) : (a.to_s.."#{b}")).include?((a + 1).to_s)
  ins += 1 if covers((a.to_s.."#{b}"), (a + 1).to_s)
  ins += 1 if covers(made(a, b), (a + 1).to_s)
  ins += 1 if with_range((a.to_s..b.to_s)) { |r| r.cover?((a + 1).to_s) }
  ins += 1 if (buf..b.to_s).cover?((a + 1).to_s)
  ins += 1 if made(a, b).eql?((a.to_s..b.to_s))
  ins += 1 if (a.to_s.."#{b}").cover?(pick(a + 1, 0))
  ins += 1 if (a.to_s.."#{b}") == made(a, b)
  ins += 1 if made(a, b) != (sa.succ..b.to_s)
  outs += 1 if made(a, b).cover?(sa.succ)
  outs += 1 if (i.odd? ? (a.to_s..b.to_s) : (a.to_s.."#{b}")).include?(sa.succ)
  outs += 1 if covers((a.to_s.."#{b}"), sa.succ)
  outs += 1 if covers(made(a, b), sa.succ)
  outs += 1 if with_range((a.to_s..b.to_s)) { |r| r.cover?(sa.succ) }
  outs += 1 if (buf..b.to_s).cover?(sa.succ)
  outs += 1 if made(a, b).eql?((sa.succ..b.to_s))
end
p ins, outs

# a global's Range, read as a receiver while its argument binds the global
# to another Range: the Range read is the one the call started with
$g = ("a".."c")
def rebind(i)
  $g = ("x".."z")
  junk = []
  200.times { |k| junk << (i + k).to_s * 3 }
  (i + 1).to_s
end

bad = 0
1000.times do |i|
  x = (i + 1).to_s
  want = i.to_s <= x && x <= (i + 5).to_s
  $g = (i.to_s..(i + 5).to_s)
  bad += 1 if $g.cover?(rebind(i)) != want
  $g = (i.to_s..(i + 5).to_s)
  bad += 1 if ($g === rebind(i)) != want
end
p bad
