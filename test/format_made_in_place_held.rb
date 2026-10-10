# `fmt % args` builds two things, the format and the list of arguments.
#
# A format made where it is written (an interpolation, a call's result) was
# held by nothing while the arguments were built, and the one-element list
# a single argument goes into was held by nothing while that argument was
# built: whichever was made first could be collected by the making of the
# other.
# spinel: gc-stress
w = 5
i = 7
ints = [3, 4]
p "%#{w}d %d|" % ints
floats = [1.5, 2.5]
p "%#{w}.1f %.1f|" % floats
strs = ["a", "b"]
p "%#{w}s %s|" % strs
mixed = [1, "x", :s]
p "%#{w}d %s %s|" % mixed
p "%#{w}d %s|" % [i, "x" + i.to_s]

# one argument
p "%#{w}d|" % i
p "%#{w}s|" % ("q" + i.to_s)
p "%5s|" % ("q" + i.to_s)
p "%-5s|" % :sym.to_s.upcase
either = [1, "two"][i & 1]
p "%#{w}s|" % either

# a number a call answers is taken before the list is made
def sq(i) = i * i
def half(i) = i / 2.0
def label(i) = "s" + i.to_s
p "%5d|" % sq(i)
p "%5.2f|" % half(i)
p "%#{w}d|" % (sq(i) + i)
p "%5d|" % (i > 3 ? sq(i) : 0)
p "%5.1f|" % (h = half(i))
def cell(i) = "%5d|" % yield(i)
p cell(i) { |v| v * v }
p "%5s|" % label(i)

# a call's result as the format
def fmt(w) = "%" + w.to_s + "d|"
p fmt(4) % 12
p fmt(4) % ints
p (fmt(3) + "%s|") % [i, "z" * 3]

# the format's nil check is kept
def no_format(c) = c ? "%d" : nil
begin
  no_format(false) % ints
rescue NoMethodError => e
  p e.class
end

# a format held ahead of its arguments is the String they change in place,
# and an interpolation reads its variable before an argument writes it
$fmt = +"%d"
def held = $fmt
def grow = ($fmt << "|%d"; 1)
p held % [grow, 2]
p "%#{w}d|%d" % [(w += 1), 2]
p "%#{w}d|" % (w += 1)
p "%#{w}d|%d" % (w += 1; ints)

# a format the statement makes is a String of its own: what an argument
# appends to the one it was made from comes after
def grow_s(s) = (s << "|x"; 1)
sb = +"%d"
p "#{sb}" % (grow_s(sb) + 1)
p (sb + "") % (grow_s(sb) + 1)
p "#{sb}|" % (grow_s(sb) + 1)
p sb

# a call that answers the format ahead of a global's read runs once
$n = 0
def counted = ($n += 1; "%d|")
p counted % $n

# a constant and a global changed in place are read as a copy where Strings
# are shared (--share-strings), and such a copy is a format made in place
KF = +"%5d"
KF << "|"
$gf = +"%3d"
$gf << "|"
p KF % 7
p $gf % (w + 1)
