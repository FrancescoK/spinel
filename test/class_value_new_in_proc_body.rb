# An object allocated inline (a Class value's `new` into an initialize whose
# default reads the instance, or `allocate`) inside a block compiled as a
# proc.

class F
  def initialize(b, a = seed) = (@a = a; @b = b)
  def seed = 42
  def show = "F #{@a} #{@b}"
end

class G
  def initialize(b) = @b = b
  def show = "G #{@b}"
end

S = Struct.new(:x, :y)

mk = proc { |k, i| k.new(i) }
al = proc { F.allocate }
puts mk.call(F, 1).show
puts mk.call(G, 2).show
p al.call.class

[F, S].each do |k|
  [[3, 4, 5], [6]].each do |args|
    r = args.size == 1 ? k.new(args[0]) : k.new(args[0], args[1], args[2])
    p r.class
  rescue ArgumentError => e
    puts e.message
  end
end

fib = Fiber.new { Fiber.yield G.allocate.class }
p fib.resume
