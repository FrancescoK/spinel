# A bare readline reads ARGF's next line, as gets does, and raises EOFError
# at the end of the input. It was given no type: `readline.strip` did
# not build.
def ask
  print "name? "
  readline.strip
end
puts "got #{ask}"
x = readline
p x
begin
  readline
  readline
rescue EOFError => e
  p [e.class, e.message]
end
