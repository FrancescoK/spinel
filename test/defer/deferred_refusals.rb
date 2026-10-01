# Compiled with --defer-refusals: a refused method compiles to a raise
# of NotImplementedError naming the refusal, and a refused statement in a
# class body or at top level is left out, while the rest of the program
# builds and runs. Without the flag the same program is refused.
def normalize(s) = s.unicode_normalize(:nfc)

class Thing
  puts "before"
  "a".unicode_normalize(:nfc)
  puts "after"
end

puts "top"
"a".unicode_normalize(:nfd)
begin
  normalize("a")
rescue NotImplementedError => e
  puts e.class
  puts e.message.include?("unicode_normalize")
end
puts "done"
