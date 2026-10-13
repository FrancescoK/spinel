# an object of a class with no inspect of its own, held in a Hash or an
# Array, renders by the default #<Name:0x... @ivar=...>, whatever the class's
# storage (the address varies run to run, so it is blanked here)

class N
  def initialize(x) = @x = x
end

class P
  def initialize(a, b)
    @a = a
    @b = b
  end
end

class Q
  def initialize(v) = @v = v
  def to_s = "Q#{@v}"
end

def bare(s) = s.gsub(/0x\h+/, "0x")

puts bare({k: N.new(5)}.inspect)
puts bare([P.new(1, "s")].inspect)
puts bare({q: Q.new(2)}.inspect)
puts Q.new(3)
