# A top-level `return` in a required file ends that file's load, after its
# ensure, and the requiring file goes on; BEGIN runs first, when it loads.
puts "main"
require_relative "return_lib"
puts "back"
