# Array#* with an argument that is neither a String nor an Integer count
# raises TypeError, in call and operator-assignment form.
def try
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

a = [0, 1]
try { p a * [1] }
try { p a * { k: 1 } }
try { p a * :s }
try { p a * nil }
try { p a * (1..2) }
s = %w[x y]
try { p s * [1] }
f = [1.5]
try { p f * [2] }
m = [1, "a"]
try { p m * [2] }
try { a *= [3]; p a }
p a
$g = [1]
try { $g *= [2] }
p $g
class K
  @@c = [1]
  def self.go
    @@c *= [3]
  end
  def self.c = @@c
  def initialize = @a = [1, 2]
  def upd(x) = @a *= [x]
  attr_reader :a
end
try { K.go }
p K.c
k = K.new
try { k.upd(1) }
p k.a
try { x = (a *= [9]); p x }
p a * 2
p s * "-"
