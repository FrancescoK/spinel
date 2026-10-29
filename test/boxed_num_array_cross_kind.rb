# An Integer Array or a Float Array read out of a mixed Array is a boxed
# value. include? and delete compare its elements with == as CRuby does,
# so an Integer finds the Float of its value and a Float the Integer.
b = [[1, 2], [1.0, 2.0], "s"]
p b[0].include?(2.0)
p b[0].include?(2.5)
p b[1].include?(2)
p b[1].include?(3)
p b[0].include?(2r)
p b[1].include?(1r)

# a boxed needle of another kind
x = [2.0, 2][ARGV.size]
y = [2, 2.0][ARGV.size]
z = [nil, 1][ARGV.size]
p b[0].include?(x)
p b[1].include?(y)
p b[0].include?(z)
p b[0].include?("2")

# delete of a Float of an Integer's value removes it and answers the element
c = [[1, 2, 1], "s"]
r = c[0].delete(1.0)
p r, r.class, c
p c[0].delete(2.5), c
p c[0].delete(-0.0), c
d = [[0, 3], "s"]
p d[0].delete(-0.0), d

# a needle whose own == allocates, many times over (the copy the compare
# reads stays alive)
class W
  def initialize(v) = @v = v
  def ==(o)
    s = "x" * 100
    [s, s].size == 2 && o == @v
  end
end
e = [[1, 2, 3, 4, 5, 6, 7, 8], [1.0, 2.0, 3.0], "s"]
n = 0
300.times do |i|
  w = [W.new(i % 9), 1][ARGV.size]
  n += 1 if e[0].include?(w)
  n += 1 if e[1].include?(w)
end
p n

# a needle whose == grows or empties the Array: include? reads the Array
# itself, so it sees the change as CRuby does
class G
  def initialize(a) = @a = a
  def ==(o)
    @a << 9 if o == 1
    o == 9
  end
end
class Z
  def initialize(a) = @a = a
  def ==(o) = (@a.clear; false)
end
ga = [1, 2]
gf = [1.0, 2.0]
gz = [1, 2]
h = [ga, gf, gz, "s"]
p h[0].include?([G.new(ga), 1][ARGV.size]), ga
p h[1].include?([G.new(gf), 1][ARGV.size]), gf
p h[2].include?([Z.new(gz), 1][ARGV.size]), gz
