# A write the load phase may not run is no write on every path: one in an
# iterator's block (which may run no time) or in a begin body with a rescue
# clause (a raise skips the rest) leaves the global or main's instance
# variable nil for a later read. A write in a class body always runs.
def boom = raise("boom")

[].each { |x| $count = x }
p $count
0.times { @items = [1] }
p @items
begin
  boom
  $total = 1
rescue
end
p $total
class Holder
  $size = 3
end
p $size + 1
[1, 2].each { |x| $last = x }
p $last
