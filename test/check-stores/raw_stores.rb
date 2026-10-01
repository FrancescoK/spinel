# A store the --check-stores self-check finds in the C emitted for this
# program: it writes a value into a C slot of another C type with no
# conversion. check-stores-test (Makefile) lists the lines it must report.
a = [1, 2]
a.fill { |i| "x" }
p a
