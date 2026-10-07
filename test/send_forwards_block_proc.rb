# A method that forwards its block through send(:m, ..., &blk) -- or `...`
# -- to a method taking `&block` is inlined at its call sites; a caller
# that handed it a real proc (`fw(&pr)`) had the proc dropped, and the
# target saw no block. The target now receives that proc, as it receives
# a literal block.

class Integer
  def pk(&b) = b ? b.call(self) : :none
end

class Picker
  def pick(x, &b) = b ? b.call(x) : :none
  def self.cpick(x, &b) = b ? b.call(x) : :none
end

def pick(x, &blk) = blk ? blk.call(x) : :none

def a1(...) = send(:pick, ...)
def a2(x, &) = send(:pick, x, &)
def a3(x, &b) = __send__(:pick, x, &b)
def a4(x, &b) = Picker.new.send(:pick, x, &b)
def a5(x, &b) = Picker.send(:cpick, x, &b)
def a6(x, &b) = x.send(:pk, &b)
def a7(x, &b) = Picker.new.public_send(:pick, x, &b)

pr = proc { |x| x * 2 }
lm = ->(x) { x * 3 }
%i[a1 a2 a3 a4 a5 a6 a7].each do |m|
  p [m, send(m, 6, &pr), send(m, 6, &lm), send(m, 6, &:to_s), send(m, 6)]
end
p [a1(6, &pr), a1(6) { |x| x + 1 }]
p [a2(6, &pr), a2(6) { |x| x + 1 }]
p [a3(6, &pr), a3(6) { |x| x + 1 }]
p [a4(6, &pr), a4(6) { |x| x + 1 }]
p [a5(6, &pr), a5(6) { |x| x + 1 }]
p [a6(6, &pr), a6(6) { |x| x + 1 }]
p [a7(6, &pr), a7(6) { |x| x + 1 }]
