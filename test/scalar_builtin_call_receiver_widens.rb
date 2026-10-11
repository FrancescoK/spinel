# A call that names a builtin Integer method on a parameter the rounds
# first type Integer, then widen with an object of a class that answers
# the name: each value takes its own method.

class Rec
  attr_reader :bit_length
  def initialize(n) = (@bit_length = n)
  def digits = [@bit_length]
  def gcd(other) = other
end

def bit_length_of(m) = m.bit_length
def digits_of(m) = m.digits
def gcd_of(m, x) = m.gcd(x)

p bit_length_of(255), digits_of(123), gcd_of(12, 8)
[Rec.new(3), Rec.new(4)].each do |r|
  p bit_length_of(r), digits_of(r), gcd_of(r, 8)
end
p bit_length_of(1024), gcd_of(9, 6)
