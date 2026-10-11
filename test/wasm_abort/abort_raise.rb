# spinel: wasm-abort
# spinel: wasm-abort-raises: bad input
# A raise with nothing to catch it reports itself as uncaught and traps, the
# host's failure; an ensure it passes is not run (#8401).
puts "before"
def check(n) = n > 2 ? raise(ArgumentError, "bad input") : n
p check(1)
p check(ARGV.size + 3)
puts "not reached"
