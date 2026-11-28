# A `break` in the block a yielding initialize runs leaves `new` with the
# break's value, and a yield whose block leaves by a jump hands no value.

class Bare
  attr_reader :b
  def initialize; @b = yield; end
end
class Given
  attr_reader :b
  def initialize = (@b = block_given? ? yield : :none)
end
class Looped
  attr_reader :b
  def initialize; @b = []; 3.times { |i| @b << yield(i) }; end
end
class Parent
  attr_reader :b
  def initialize; @b = yield; end
end
class Child < Parent
  def initialize; super; @c = 1; end
end
class Amp
  attr_reader :b
  def initialize(&b); @b = b.call; end
end
class Args
  attr_reader :b
  def initialize(a, k: 1); @b = yield(a + k); end
end
class Guarded
  attr_reader :b
  def initialize
    @b = yield
  ensure
    $ens = :ens
  end
end
class Twice
  attr_reader :b
  def twice = yield
  def initialize; @b = twice { yield }; end
end
class Sub < Given; end
S = Struct.new(:a) do
  def initialize; super(yield); end
end
C = Class.new do
  attr_reader :b
  def initialize; @b = yield; end
end

def show(x) = (x.respond_to?(:b) && !x.is_a?(String) ? [:obj, x.b] : x)

$c = true
p Bare.new { break :b }, Given.new { break :g }, Looped.new { |i| break i * 10 if i == 1; i }
p Child.new { break :c }, Amp.new { break :a }, Args.new(1, k: 2) { |v| break v * 2 }
p Bare.new { break }, Given.new { break nil }, Given.new { break 1, 2 }
p show(Given.new { break :b if $c; 3 })
$c = false
p show(Given.new { break :b if $c; 3 }), show(Looped.new { |i| i }), show(Args.new(1) { |v| v })
v = ARGV.empty? ? 1 : "s"
w = ARGV.empty? ? nil : 2
p Given.new { break v }, Given.new { break w }, Given.new { break w }.nil?
p [show(Given.new { break :a }), show(Given.new { 3 })], [Bare.new { break :x }, Bare.new { break :y }]
def mk_tail = Given.new { break :t }
p mk_tail
x = Given.new { break 4 }
p x + 1, "v=#{Given.new { break 7 }}", Given.new { break nil }&.b, Given.new { 2 }&.b
p show(Guarded.new { break :e }), $ens
p show(Twice.new { break :l2 }), show(Twice.new { 2 })
p show(Sub.new { break :z }), show(Sub.new { 1 })
p S.new { break :s }, S.new { 1 }.a, C.new { break :k }, C.new { 2 }.b
p show(Bare.new { Bare.new { break :inner }; 3 }), show(Bare.new { Bare.new { 1 }; break :outer })
p [1, 2].map { |i| show(Given.new { break i if i == 1; i * 10 }) }
[1, 2].each { |i| p Given.new { break i } }
l = -> { Given.new { break :lb } }
p l.call, l.call
def ret_m
  Given.new { return :r }
  :no
end
p ret_m

