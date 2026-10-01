# Stores the --check-stores self-check finds in the C emitted for this
# program: each writes a value into a C slot of another C type with no
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
p big.div(1.5)
p Complex(big, 1)
