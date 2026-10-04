# A method called on a local or global object slot that a write sets to nil
# ran with a NULL self (answering as if the receiver were an instance) or
# crashed reading an ivar, where CRuby raises NoMethodError (#7262).
class Box
  attr_accessor :v

  def initialize(v)
    @v = v
  end

  def hello
    "hello"
  end

  def touch
    @v += 1
    nil
  end
end

def run(label)
  yield
rescue NoMethodError => e
  puts "#{label}: #{e.message}"
end

b = nil
b = Box.new(1) if ARGV.size > 5

begin
  puts b.hello
rescue NoMethodError => e
  puts "hello: #{e.message}"
end

begin
  puts b.v
rescue NoMethodError => e
  puts "v: #{e.message}"
end

begin
  b.touch
rescue NoMethodError => e
  puts "stmt: #{e.message}"
end

run("setter") { b.v = 3 }
run("assign") { x = b.v; p x }
run("interp") { puts "#{b.hello}" }

c = ARGV.size > 5 ? Box.new(2) : nil
run("ternary") { p c.v }

d = Box.new(3)
p d.v
d = nil if ARGV.size > 9
p d.v

$g = nil
$g = Box.new(4) if ARGV.size > 5
run("global") { p $g.v }
$g = Box.new(5)
p $g.v
