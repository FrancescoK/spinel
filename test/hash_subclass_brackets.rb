# H[...] for a Hash subclass H makes an H from the same arguments Hash[]
# takes: alternating keys and values, one Hash, a list of pairs, a splat.
# Hash#initialize and H's own initialize are not called. An odd count of
# keys and values raises ArgumentError, for Hash[] too.

class H < Hash
  def initialize(*) = (puts "init"; super)
  def keys2 = keys.map(&:to_s)
end

class J < Hash
  def to_h = {over: 1}
end

class G < Hash
  def self.[](*a) = "own #{a.size}"
end

a = H[]
p a, a.class
b = H["s", 1, "t", 2]
p b, b.class, b.keys2
c = H[b]
p c, c.class, c.equal?(b)
d = H[1, "x", :y, 2.5]
p d
p H[{w: 4}], H[{w: 4}].class
p H[[[:b, 2]]], H[[[:b, 2]]].class
p G[1, 2]

def mk(k, v) = H[k, v]
m = mk(:q, [1])
p m, m.class
m[:r] = [2]
p m.size

x = [[1, 2], [3, 4]]
p H[x], H[x].class
args = [:k, :v]
p H[*args], H[*args].class

begin
  H[1, 2, 3]
rescue ArgumentError => e
  p e.message
end
begin
  Hash[1, 2, 3]
rescue ArgumentError => e
  p e.message
end

# a new H of the pairs: not the argument, nor its default or default proc,
# and not through the class's own to_h
dd = Hash.new(5)
dd[:a] = 1
x2 = H[dd]
p x2, x2[:zz], x2.default, x2.equal?(dd)
dp = Hash.new { |hh, k| k.to_s * 2 }
dp[:b] = 2
y2 = H[dp]
p y2[:qq], y2.default_proc.nil?
j = J[:a, 1]
p J[j], J[j].class, J[j].equal?(j)

f = H[a: 1].freeze
p f.frozen?, f.class

class A < Array; end
p A[1, 2], A[1, 2].class

# splats among the arguments: the count is known at run time
sa = [1, 2]; sb = [3, 4]
p Hash[*sa, *sb], H[*sa, *sb], H[*sa, *sb].class
sr = [:v]
p Hash[:k, *sr], H[:k, *sr].class
se = []
p Hash[*se, *se], H[*se, *se].class
