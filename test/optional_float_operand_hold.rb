# nullable Float held ahead of an effectful operand
class FS
  def initialize(set) = (@f = 1.5 if set)
  def side = (puts "fside"; 2)
  def two(a, b) = [a, b]
  def call3 = two(@f, side)
  def fmt = format("%p|%p", @f, side)
  def eqq = @f.eql?(side.to_f)
  def arr = [@f, side]
end
$gf = 2.5 if ARGV.size > 3
def gside = (puts "gside"; 1)
[false, true].each do |set|
  f = FS.new(set)
  p f.call3, f.fmt, f.eqq, f.arr
end
p [$gf, gside]
p format("%p", $gf)
