# The words load, autoload and $LOAD_PATH in a comment or a String load no
# file: the program is read as one that can load nothing it did not read, as
# a program without them is. (tools/load_graph_check.sh holds the C to that.)
#
# load "x"; autoload :X, "x"; $LOAD_PATH << "dir"; $: $-I $LOADED_FEATURES $"
# spinel: gc-stress
words = ["load", "autoload", "$LOAD_PATH", "$:", "$-I", "$LOADED_FEATURES", "$\""]
p words.map(&:size)
puts "load 'x' #{words.size} autoload"
puts <<~TEXT
  $LOAD_PATH << "dir" and load("y")
TEXT

# a multiple assignment's new Strings are held as their handles where the
# program gives a class no []=, +@ or dup of its own
r = [+"q"]
r[0], r[1] = +"ab", +"cd"
r[0] << "z"
r[1] << "!"
p r
