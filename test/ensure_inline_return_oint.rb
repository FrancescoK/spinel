# A yielding method with ensure spliced into a method whose Integer answer
# can be nil: the ensure's deferred return left that C function with a
# plain Integer where it returns the oint, and the C did not build (#10015).
# The block's own return leaves the caller through the same ensure.
def wrap
  yield
ensure
  puts "done"
end
def step(n)
  wrap { return n * 10 if n > 5; n } if n > 0
end
p step(1), step(7), step(0)
