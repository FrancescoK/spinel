# A Method's proc called with more than 16 values, by a splat or written
# out. The bound Method trampoline is handed the true count and reads that
# many argument slots, but the call filled an array of 16: the 17th
# argument of a 17-parameter method read the stack past it and answered
# garbage. A count past the method's own arity is still its ArgumentError.
class Wide
  def m17(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, pp, q) = [a, pp, q]
  def m18(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, pp, q, r) = q + r
end
args = (1..17).to_a
w = Wide.new
p w.method(:m17).to_proc.call(*args)
p w.method(:m17).call(*args)
p w.method(:m18).to_proc.call(*(10..27).to_a)
words = %w[a b c d e f g h i j k l m n o p q]
p w.method(:m17).to_proc.call(*words)
begin
  w.method(:m17).to_proc.call(*(1..20).to_a)
rescue ArgumentError => ex
  puts ex.message
end
pr = w.method(:m17).to_proc
p pr.call(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
p pr.(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
p pr["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q"]
