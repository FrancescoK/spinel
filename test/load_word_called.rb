# A program that calls load, or reads or writes the load path, may load a file
# the compiler did not read, and is read as one that can give any class any
# method: its answers stay the general ones. (tools/load_graph_check.sh holds
# the C to that; Spinel does not compile a Kernel#load itself, so the call is
# a def of the program's own.)
# spinel: gc-stress
def load(name) = name.size

p load("abc")
$LOAD_PATH.unshift("dir")
p $LOAD_PATH.first
p $:.size > 0

r = [+"q"]
r[0], r[1] = +"ab", +"cd"
r[0] << "z"
r[1] << "!"
p r
