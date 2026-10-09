# values_at on a boxed receiver collects its indexes one statement each. An
# index that is built where it stands (a Range whose bound needs a statement
# of its own, a list that holds a splat) has those statements ahead of the
# one that takes the index, not inside it.

a = [[1, 2, 3], nil][ARGV.size]
p a.values_at(0..[1].size)
p a.values_at(0...[1, 2].size, [0].size)
p a.values_at(([1].empty? ? 0 : 1)..2)
p a.values_at((x = [1].size)..2)
p x
p a.values_at([0].size..)
p a.values_at(..[1].size)

# a splatted list that holds a splat
p a.values_at(*[*[0], 1])
p a.values_at(*[0, *[1]])
p a.values_at([0].size..[1].size, *[[0, 1].size])

# an Array is no index, built in place or not
begin
  a.values_at(0, [0])
rescue TypeError => e
  puts e.message
end

# a mixed Array, and a Hash, whose key the Range is
b = [[10, "s", :z], nil][ARGV.size]
p b.values_at([1].size..2, 0)
h = [{(0..1) => :r, 1 => :o}, nil][ARGV.size]
p h.values_at(0..[1].size, 1)

# an index that needs no statement, and one that runs ahead of the call,
# answer as before
p a.values_at(0..1)
p a.values_at(0, [1].size)
p a.values_at(*[0, [1].size])
r = 0..[1].size
p a.values_at(r)
