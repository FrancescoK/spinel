# A SIGINT that arrives while a loop that computes only on scalars stores
# where a rescue can read it: an instance variable, a Struct member and an
# attribute through their writers, a local a proc captured. Such a loop polls
# once per run of passes (a chunked loop), and the C compiler has made the
# stores ahead of that poll, so each rescue reads the value the loop got to,
# not the one from before it (raised where the signal landed, it read 0.0).
# The second loop is a counted one, whose runs end at a computed bound. Each
# loop's signal comes from a child started just ahead of it, so it lands in
# that loop however long the rescue before it took. The last loop steps two
# instance variables together, and the caller's rescue reads them in step.
$stdout.sync = true
P = Struct.new(:x)
class K
  attr_accessor :y
  attr_reader :z, :a, :b
  def initialize; @y = 0.0; @z = 0.0; @a = 0; @b = 0; end
  def spin; while true; @z = @z + 1.0; end; end
  def pair; while true; @a += 1; @b += 1; end; end
end
pid = Process.pid
k = K.new
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  k.spin
rescue Interrupt
  puts(k.z > 0 ? "ivar advanced" : "ivar stale")
end
o = P.new(0.0)
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  i = 0
  while i < 4_000_000_000_000
    o.x = o.x + 1.0
    i += 1
  end
rescue Interrupt
  puts(o.x > 0 ? "struct advanced" : "struct stale")
end
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  while true
    k.y = k.y + 1.0
  end
rescue Interrupt
  puts(k.y > 0 ? "attr advanced" : "attr stale")
end
x = 0.0
pr = -> { x }
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  while true
    x = x + 1.0
  end
rescue Interrupt
  puts(pr.call > 0 ? "cell advanced" : "cell stale")
end
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  k.pair
rescue Interrupt
  puts(k.a == k.b && k.a > 0 ? "ivar pair in step" : "ivar pair out of step")
end
