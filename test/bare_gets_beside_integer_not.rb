# A zero-argument `~` anywhere in the program made bare_gets_scan treat it as
# reading $_ (Regexp#~), so a bare gets or readline lost its ARGF reading and
# was refused at its first use. `~5` and `~x` are Integer#~, and Spinel's own
# Integer#bit_length spells `~self`, so `require "securerandom"` alone did it.
# Only a regexp literal receiver counts as the $_ match now.
require "securerandom"
p(~5)
x = 7
p(~x)
p SecureRandom.hex(2).size
puts gets.strip
puts readline.strip
p gets
