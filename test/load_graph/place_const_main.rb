# The file reads LIMIT before the entry writes it, in its one require under a
# condition (placed where the require stands).
require_relative "place_const_lib" if ARGV.empty?
LIMIT = 5
p LIMIT
