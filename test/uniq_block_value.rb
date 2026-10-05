# Array#uniq! with a block answers the receiver when the block's keys
# removed an element, and nil when they removed none, as uniq! without a
# block does. It answered nil either way. A block that binds no parameter,
# an empty block and a Proc passed with & key the elements too; the first
# two were ignored on the typed arrays, and uniq(&pr) on a String array
# kept every element.

a = [3, 1, 2, 3]
p a.uniq! { |x| x % 2 }, a
a = [1, 2]
p a.uniq! { |x| x }, a
f = [1.5, 2.5, 1.5]
p f.uniq! { |x| x.floor }, f
s = ["bb", "a", "cc"]
p s.uniq! { |x| x.size }, s
m = [1, "x", :s, 1]
p m.uniq! { |x| x.class }, m
r = [3, 3].uniq! { |x| x }
p r.nil?, r

p [3, 1, 2].uniq { 0 }, ["a", "b"].uniq { }, [1.5, 2.5].uniq { :k }
b = [3, 1, 2]
p b.uniq! { 0 }, b
b = [4, 5]
p b.uniq! { }, b
p [1].uniq! { 0 }, [].uniq! { 0 }
p [3, 1, 2].uniq { _1 % 2 }, [3, 1, 2].dup.uniq! { it % 2 }

pr = proc { |x| x.to_s.size }
p ["bb", "a", "bb"].uniq(&pr), ["bb", "a", "bb"].uniq!(&pr), [1, 22, 3].uniq(&pr)
len = ->(x) { x.abs }
p [1, -1, 2].uniq(&len), [1, -1, 2].uniq!(&len)
p [[1, 2], [1, 3]].uniq { |a, b| a }, [[1, 2], [1, 3]].uniq!(&:first)

def dedup(arr) = arr.uniq! { |x| x.to_s }
p dedup([1, 1, 2]), dedup([1, 2])
