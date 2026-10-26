# A raise in a required file's top level leaves the requiring file there,
# and the program, uncaught.
# spinel: exit 1
puts "before"
require_relative "raise_lib"
puts "after"
