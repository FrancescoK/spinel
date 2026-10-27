# A file required under a condition and then again at the top level runs
# once, at whichever require runs first.
require_relative "place_cond_top_lib" if ARGV.empty?
p Foo.new.hi
require_relative "place_cond_top_lib"
p Foo.new.hi
puts "main"
