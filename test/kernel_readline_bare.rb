# A bare readline is ARGF.readline: the next line of input, a String a call
# can be made on, and EOFError at the end, where gets answers nil (#7201).
def ask
  print "name? "
  readline.strip
end

puts "got #{ask}"
puts "got #{ask}"
line = readline
p line
begin
  readline
rescue EOFError => e
  p e
end
