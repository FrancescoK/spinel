# Kernel#rand / Random#rand / Random.rand over a Range that is not a literal
# at the call: a parameter, a variable, a value out of a mixed slot.
# `def roll(r) = rand(r)` answered nil (as a method's last expression the
# statement form of rand dropped its draw; srand and putc lost theirs the
# same way), a boxed Range was converted to an Integer bound and raised
# TypeError, an open Range drew from the sentinel span instead of raising
# Errno::EDOM, and a Range whose end is written as a Float drew an Integer.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue Exception => e
  puts "#{s}: #{e.class}: #{e.message}"
end

def kind(x) = x.nil? ? nil : x.class
def roll(r) = rand(r)
def roll2(r)
  rand(r)
end
def rroll(r) = Random.new(1).rand(r)
def croll(r) = Random.rand(r)
def seed = srand(5)
def put = putc("x")

puts "-- parameters"
x = roll(1..10); t("roll") { [kind(x), (1..10).include?(x)] }
x = roll2(1..10); t("roll2") { [kind(x), (1..10).include?(x)] }
x = rroll(1..10); t("Random#rand") { [kind(x), (1..10).include?(x)] }
x = croll(1..10); t("Random.rand") { [kind(x), (1..10).include?(x)] }
t("empty") { roll(5..1) }
t("Random#rand empty") { rroll(5..1) }
seed
t("srand") { seed }
t("putc") { put }

puts "-- variables"
r = (1..10)
t("var") { x = rand(r); [kind(x), r.include?(x)] }
e = (1..)
t("open") { rand(e) }
t("Random#rand open") { Random.new(1).rand(e) }
f = (1..2.5)
t("float end") { x = rand(f); [kind(x), x >= 1 && x <= 2.5] }
t("literal float end") { x = Random.new(1).rand(1..2.5); [kind(x), x >= 1 && x <= 2.5] }

puts "-- boxed"
vals = [1..10, 5..1, 1...1, 1.., ..5, 1.0..2.0, 1..2.5, 3, 0, -4, 2.5, nil, "x", 2**70]
vals.each do |v|
  t("K #{v.inspect}") { kind(rand(v)) }
  t("R #{v.inspect}") { kind(Random.new(1).rand(v)) }
  t("RC #{v.inspect}") { kind(Random.rand(v)) }
end
