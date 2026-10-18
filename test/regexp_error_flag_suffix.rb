# CRuby quotes a pattern that failed to compile with the flags it was given,
# `/pattern/x`, so the message can be pasted back into Regexp.new to reproduce
# the failure. The message carried no such suffix, whatever the flags were.
# (ported from mruby-regexp a23691440 and 24fb9124a)
def show(src, flags)
  Regexp.new(src, flags)
  puts "compiled"
rescue RegexpError => e
  puts e.message
end

show('[z-a]', 0)
show('[z-a]', Regexp::IGNORECASE)
show('[z-a]', Regexp::EXTENDED)
show('[z-a]', Regexp::MULTILINE)
show('[z-a]', Regexp::IGNORECASE | Regexp::EXTENDED)
show('[z-a]', Regexp::IGNORECASE | Regexp::MULTILINE)
show('[z-a]', Regexp::EXTENDED | Regexp::MULTILINE)
show('[z-a]', Regexp::IGNORECASE | Regexp::EXTENDED | Regexp::MULTILINE)

# The suffix follows the flags the pattern was compiled WITH, not what an
# inline option leaves active partway through the parse.
show('(?i)[z-a]', 0)
show('(?-i)[z-a]', Regexp::IGNORECASE)
show('(?m)[z-a]', 0)
show('(?-m)[z-a]', Regexp::MULTILINE)

# and it is the same rendering, in the same order, that Regexp#inspect uses
p Regexp.new('a', Regexp::IGNORECASE | Regexp::EXTENDED | Regexp::MULTILINE).inspect
p Regexp.new('a', Regexp::MULTILINE).inspect
p Regexp.new('a', 0).inspect

# a few other refusals carry it too; `\R`, which this engine refused once, now
# compiles as CRuby's does
show('(?<1>a)', Regexp::MULTILINE)
show('[a-\d]', Regexp::IGNORECASE)
show('\R', Regexp::EXTENDED)
