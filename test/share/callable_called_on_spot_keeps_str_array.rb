# A program whose procs are only called where they are made (a lambda
# called at once, a block parameter called, tested or handed on with `&`)
# puts no proc in a box, so a boxed receiver's `[]` is no Proc#[] call and
# its argument does not join every other unknown value (#9230). A lambda
# that is kept in an Array is still called through the box, and changes
# the String it is handed.
def lookup(fields, tables)
  tables[0][fields[0]]
end

def bump(rows)
  rows[0][0] << 0
end

def each_row(rows, &blk)
  rows.each { |r| blk.call(r) if blk }
end

def relay(rows, &blk) = each_row(rows, &blk)

p lambda { 1 }.call
p lookup(["a", "b"], [{ "a" => 7 }, nil])
p bump([[[1]], nil])
out = []
relay([["x", "y"]]) { |r| out << r.join(",") }
p out

s = +"kept"
fs = [->(x) { x << "!" }, nil]
fs[0][s]
p s
