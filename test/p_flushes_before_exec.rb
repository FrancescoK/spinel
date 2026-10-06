# Kernel#p flushes stdout after writing, as CRuby's does; puts, print and pp
# leave their output in the buffer. Run with stdout to a pipe, what was not
# flushed is lost when exec replaces the process.
p 1
puts "out with the next p"
x = p(2, 3)
print "out with the next p too\n"
pp 4
y = p([5])
z = p
print "flushed by the next p: #{[x, y, z].inspect}\n"
p 6
puts "buffered, lost when exec replaces the process"
exec "echo", "replaced"
