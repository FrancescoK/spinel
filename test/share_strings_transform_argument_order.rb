# A top-level method with the same name leaves boxed String transforms to
# their own operand holds. Plain reads must precede later argument calls.
def center
  'top-level center'
end

def padding_after_width
  $width = 9
  GC.start
  'x'
end

p center
$width = 3
p [+'a', nil].first.center($width, padding_after_width)
p $width

# Parentheses still name the old value when the outer argument holds run.
$width = 3
p [+'a', nil].first.ljust(($width), padding_after_width)
$width = 3
p [+'a', nil].first.rjust(($width), padding_after_width)

width = 3
padding = -> {
  width = 9
  GC.start
  'x'
}
p [+'a', nil].first.center(width, padding.call)
p width

# Holding a String preserves its identity: reassignment replaces the slot,
# but mutation of the held String still changes the pattern the call uses.
def sub
  'top-level sub'
end

def replacement_after_rebind
  $pattern = 'b'
  GC.start
  'x'
end

p sub
$pattern = 'a'
p [+'aabb', nil].first.sub($pattern, replacement_after_rebind)
p $pattern

$pattern = 'a'
p [+'aabb', nil].first.tr(($pattern), replacement_after_rebind)
p $pattern

def replacement_after_mutation(pattern)
  pattern << 'a'
  GC.start
  'x'
end

pattern = +'a'
kept = [pattern]
p [+'aabb', nil].first.sub(pattern, replacement_after_mutation(pattern))
p kept
