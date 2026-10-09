# spinel: gc-minor
# select, reject, find_all, partition and the in-place filters over an Array
# a builtin just made (split): the Strings the block names are the ones the
# answer holds. A change made through the block's parameter, through a name the
# block leaked it to, or through the answer afterwards is seen at every name.

# the block's own change reaches the answer
p " a , b ".split(",").select { |x| x.strip!; true }
r = " a , b ".split(",").select { |x| x.strip!; true }
r[0] << "!"
p r

# a leaked name sees a change made through the answer, and the other way
keep = []
r = " c , d ".split(",").select { |x| keep << x; true }
r[0] << "!"
keep[1] << "?"
p r, keep

keep = []
r = " e , f ".split(",").reject { |x| keep << x; x == " f " }
r[0] << "1"
p r, keep

keep = []
r = " g , h ".split(",").find_all { |x| keep << x; true }
r[1] << "2"
p r, keep

keep = []
r = " i , j ".split(",").filter { |x| keep << x; true }
r[0] << "3"
p r, keep

# a dropped element is not in the answer, and its leaked name is
keep = []
r = " k , l , m ".split(",").select { |x| keep << x; x != " l " }
r[0] << "4"
keep[1] << "5"
p r, keep

# both Arrays of partition
a, b = " n , o , q ".split(",").partition { |x| x.strip!; x == "o" }
a[0] << "6"
b[1] << "7"
p a, b

# the in-place filters answer the Array itself, or nil when nothing was dropped
r = " r , s , t ".split(",").select! { |x| x.strip!; x != "s" }
r[0] << "8"
p r
p " u , v ".split(",").select! { |x| x.strip!; true }
r = " w , x ".split(",").reject! { |y| y.strip!; y == "w" }
r[0] << "9"
p r
r = " y , z ".split(",").keep_if { |x| x.strip!; x == "z" }
r[0] << "0"
p r
r = " a , b ".split(",").delete_if { |x| x.strip!; x == "a" }
r[0] << "1"
p r

# chains
p " p , q ".split(",").select { |x| x.strip!; true }.map { |y| y << "m" }
p " p , q ".split(",").reject { |x| x.strip!; false }.join("|")
p " p , q ".split(",").select { |x| x.strip!; true }.first
p " b , a ".split(",").select { |x| x.strip!; true }.sort
p " p , q ".split(",").select { |x| x.strip!; x == "q" }.size
p " p , q ".split(",").each_with_index.select { |x, i| x.strip!; i == 1 }

# a change through the source Array after the selection
src = " c , d ".split(",")
sel = src.select { |x| x.strip!; true }
src[0] << "!"
sel[1] << "?"
p sel, src

# block shapes: the elements are Strings, so extra parameters stay nil
r = " c , d ".split(",").select { |x, y| x.strip!; y.nil? }
r[0] << "!"
p r
r = " c , d ".split(",").select { |*x| x[0].strip!; true }
r[0] << "!"
p r
r = " c , d ".split(",").select { |x, *y| x.strip!; y.empty? }
r[0] << "!"
p r
p " a , b ".split(",").select { |x, *y| x << "w"; y.empty? }
r = " c , d ".split(",").select { |x = 1| x.strip!; true }
r[0] << "!"
p r
r = " c , d ".split(",").reject { it.strip!; it == "c" }
r[0] << "!"
p r
r = " c , d ".split(",").select { _1.strip!; true }
r[0] << "!"
p r
r = " c , d ".split(",").select { |x| next true if x == " c "; x.strip!; false }
r[0] << "!"
p r
r = " c , d ".split(",").select! { |x, y| x.strip!; x == "c" }
r[0] << "!"
p r
a, b = " c , d ".split(",").partition { |x, y| x.strip!; x == "c" }
a[0] << "!"
b[0] << "?"
p a, b
a, b = " c , d ".split(",").partition { _1.strip!; _1 == "c" }
a[0] << "!"
b[0] << "?"
p a, b

# builtins other than split make fresh Arrays too
r = "a1b2".scan(/\d/).select { |d| d << "x"; true }
r[0] << "!"
p r
r = "a b\nc d\n".lines.select { |l| l.chomp!; true }
r[0] << "!"
p r

# a method answering the selection
def pick(s) = s.split(",").select { |x| x.strip!; true }
r = pick(" c , d ")
r[0] << "!"
p r

# a frozen element
r = " f , g ".split(",").select { |x| x.strip!; x.freeze; x == "f" }
begin
  r[0] << "!"
rescue FrozenError
  p :frozen
end
p " a , b ".split(",").select { |x| x.frozen? }

# the block does not change its parameter: the same answers as without sharing
p "a,b,c".split(",").select { |x| x != "b" }
p "a,b,c".split(",").partition { |x| x == "a" }
p "a,b,c".split(",").reject! { |x| x == "z" }

# many rounds, collecting between them
all = []
200.times do |i|
  r = " a#{i} , b#{i} ".split(",").select { |x| x.strip!; true }
  r[0] << "!"
  all << r
end
p all.size, all[0], all[199]
