# A store the --check-stores self-check finds in the C emitted for this
# program: it writes a value into a C slot of another C type with no
# conversion. check-stores-test (Makefile) lists the lines it must report.
def bump
  $b = 0
  3
end

def big
  2**64
end

$b = big
bump
p $b
