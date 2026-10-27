# The words require and require_relative in a comment, a String or a Symbol
# are no require: the program is read as one that loads nothing it did not
# read, as a program without them is. (tools/load_graph_check.sh holds the C
# to that.)
#
# require "foo"; require_relative "bar"; Kernel.require "baz"
# spinel: gc-stress
words = ["require", "require_relative", "require 'x'", :require, :require_relative]
p words.map(&:to_s).map(&:size)
puts "require 'x' #{words.size} require_relative"
puts <<~TEXT
  require "y" and require_relative("z")
TEXT
opts = { require: 1, require_relative: 2 }
p opts

# a multiple assignment's new Strings are held as their handles where the
# program gives a class no []=, +@ or dup of its own
r = [+"q"]
r[0], r[1] = +"ab", +"cd"
r[0] << "z"
r[1] << "!"
p r
