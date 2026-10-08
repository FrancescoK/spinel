# Compiled with --defer-refusals: a refused statement in a class body
# raises NotImplementedError where it stands, so the body's later lines
# do not run as if it had not been there.
# spinel: defer-refusals: 1:before
class Thing
  puts "before"
  "a".unicode_normalize(:nfc)
  puts "not reached"
end
puts "not reached"
