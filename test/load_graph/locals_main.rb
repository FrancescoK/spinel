# Each file's top-level locals are its own: the same names in two files are
# two variables, and neither file sees the other's.
x = 1
y = "main"
require_relative "locals_lib"
puts x, y
puts defined?(z).inspect
puts $lib_proc.call(2)
