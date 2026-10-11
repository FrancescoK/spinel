# A local bound to split's Array whose Strings an each block appends to,
# inside `loop do`: the second pass appends again to the Strings the first
# one handed to `out`. Still refused, not silently applied to copies.
# spinel: reject-thread-string
out = []
a = "a;b".split(";")
n = 0
loop do
  a.each { |x| x << "!"; out << x }
  n += 1
  break if n == 2
end
p out
