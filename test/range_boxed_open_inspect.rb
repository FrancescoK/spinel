# An Integer Range with an open side, read out of a mixed slot, renders as
# the typed one does: #inspect, #to_s and interpolation leave the open side
# out. The boxed rendering printed the sentinel bound
# (-9223372036854775808..3, 1..9223372036854775807). (nil..nil) is ".."
# to #to_s, puts and print and "nil..nil" to #inspect and p.

src = [(..3), (1..), (...5), (2...), (1..4), (nil..nil), "x"]
src.each do |x|
  next if x.is_a?(String)
  p x
  puts x.to_s
  puts "in #{x} here"
end
p [(..3), (1..)]
puts(..3)
puts(nil..nil)
print((1..), "\n")
p(nil..nil)
