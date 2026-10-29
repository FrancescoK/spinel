# A top-level call with arguments before its def that nothing rescues ends
# the program with CRuby's NoMethodError. The sidecar holds the error line
# as Spinel prints it.
puts "before"
foo(1)
def foo(a) = a
puts "not reached"
