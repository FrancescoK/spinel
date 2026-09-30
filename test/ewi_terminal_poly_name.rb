# `v.each_with_index.<terminal>` on a value of no single type, in a program
# where a Struct and user classes also define the terminal's name: the call
# is typed boxed, and the fold's typed result has to be boxed with it. It
# went out raw through an sp_RbVal return and the C did not build (#6293).
Pair = Struct.new(:a, :b)
class Banking
  def map(r, w) = [r, w]
  def select(x) = [x]
  def count(x) = x
  def any?(x) = !!x
  def to_h(x) = {x => x}
end
def pick(flag) = flag ? [1, 2] : "ab"
def mapped(flag) = pick(flag).each_with_index.map { |x, i| [x, i] }
def selected(flag) = pick(flag).each_with_index.select { |x, i| i > 0 }
def counted(flag) = pick(flag).each_with_index.count { |x, i| i.even? }
def anyed(flag) = pick(flag).each_with_index.any? { |x, i| x == 2 }
def hashed(flag) = pick(flag).each_with_index.to_h
p mapped(true), selected(true), counted(true), anyed(true), hashed(true)
p Pair.new(1, 2).to_a
b = Banking.new
p b.map(1, 2), b.select(3), b.count(4), b.any?(nil), b.to_h(:k)
