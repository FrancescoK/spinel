# Array#pack on a boxed receiver answers the packed String.

class Grid
  def map
    [1]
  end
end
p Grid.new.map

x = ARGV.empty? ? [64, 65] : "AB"
p x.pack("C*")
r = x.pack("C2")
p r
p r.size

@ivar = x.pack("U*")
p @ivar
$glob = x.pack("n*")
p $glob

def packed(v) = v.pack("n")
p packed(ARGV.empty? ? [258] : "AB")

f = ARGV.empty? ? "C*" : 3
p x.pack(f)

y = ARGV.empty? ? [1.5, 2.0] : "AB"
p y.pack("e2")

z = ARGV.empty? ? ["ab", "cd"] : 1
p z.pack("a3a3")

bytes = [72, 105]
s = bytes.map { |b| b }.pack("C*")
p s
