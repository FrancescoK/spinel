# Float directives round the way CRuby's dtoa does: its fast path settles a
# remainder within its error bound of one half as a tie, to even (#7270).
# 0.69 / 6 is 0.11499999999999999112 and answers 0.12; a %g digit string
# that tie leaves untrimmed keeps its zeros.
puts format("%.2f", 0.69 / 6)
puts format("%.2f", 2.675)
puts format("%.2f", 2.345)
puts format("%.2f", 1.005)
puts format("%.2f", 0.125)
puts format("%.1f", 0.25)
puts format("%.2f", 9.045000000000005)
puts format("%.1f", 9996.250000000005)
puts format("%.4f", 9.248349999999995)
puts format("%.5g", 7.919050000000001)
puts format("%.6G", 211680500.0)
puts format("%12.5g|%-12.5g|%012.5g", 7.919050000000001, 7.919050000000001, 7.919050000000001)
puts format("%.3e", 1.7976931348623157e308)
puts format("%.15g %.17g", 0.1 + 0.2, 0.1 + 0.2)
# a field longer than the formatter's own buffer
puts format("%.2f", 1e300).size
puts format("%300d|", 5).size
puts format("%300x|", 255).size
puts format("%300d|", 2**70).size
sum = 0
2000.times do |i|
  x = ((i * 7919) % 100003 + 0.5) / 10.0**(i % 6)
  [x, x.next_float, x.prev_float].each do |y|
    sum += format("%.#{i % 5}f", y).sum + format("%.#{i % 5}e", y).sum + format("%.#{i % 5 + 1}g", y).sum
  end
end
p sum
