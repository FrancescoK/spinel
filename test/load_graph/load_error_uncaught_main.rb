# An uncaught LoadError of a require that names no file ends the program
# there, as CRuby's does.
# spinel: exit 1
puts "before"
require "load_error_uncaught_no_such_lib"
puts "after"
