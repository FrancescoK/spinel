# The readers that compare against an Integer Range's end written as a Float
# use that end: Float#clamp clamps to 2.5 (it clamped to 2) and refuses an
# exclusive one, Comparable#clamp on an object does the same, == against a
# Float range compares the end and exclusivity as written, a Range is a
# Hash key by eql? (so (1..2.5) and (1..2) are different keys), and a
# Rational is compared against the Float end.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

class V
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(o) = n <=> (o.is_a?(V) ? o.n : o)
  def inspect = "V(#{n})"
end

def run(r, i)
  t("#{i} clamp") { [2.7.clamp(r), 0.5.clamp(r), 1.5.clamp(r)] }
  t("#{i} clamp obj") { [V.new(7).clamp(r), V.new(0).clamp(r)] }
  t("#{i} == float range") { [r == (1.0..2.5), r == (1.0...2.5), r == (1.0..2.0)] }
  t("#{i} hash key") { h = { r => 1 }; [h[(1..2.5)], h[(1..2)], h[(1...2.5)]] }
  t("#{i} rational") { [r.cover?(Rational(5, 2)), r.include?(Rational(9, 4))] }
end
run((1..2.5), 0)
run((1...2.5), 1)
run((1..2), 2)

puts "-- boxed"
mix = [(1..2.5), (1...2.5), "x"]
2.times do |i|
  r = mix[i]
  t("#{i} === rational") { r === Rational(5, 2) }
  t("#{i} hash key") { h = { r => 1 }; [h[(1..2.5)], h[(1..2)], h[(1...2.5)]] }
end
