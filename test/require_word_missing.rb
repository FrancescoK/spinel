# A require that names no file may load one the compiler did not read, and
# the program is read as one that can give any class any method, though the
# require never runs here. (tools/load_graph_check.sh holds the C to that.)
# spinel: gc-stress
require "no_such_file_for_require_word_missing" if ARGV.size > 5

r = [+"q"]
r[0], r[1] = +"ab", +"cd"
r[0] << "z"
r[1] << "!"
p r
