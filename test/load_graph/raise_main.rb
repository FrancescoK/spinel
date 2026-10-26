# A raise in a required file's top level leaves the requiring file there.
puts "before"
require_relative "raise_lib"
puts "after"
