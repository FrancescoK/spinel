# A block that appends to the element a chained index binds -- `a.each.
# with_index`, `a.map.with_index`, `a.each.each_with_index`, and a Hash's
# `each_value.with_index` / `each_value.each_with_index` -- appends to the
# String the container stores. The element went to a copy; through a Hash's
# values the block's parameter was typed a String Array from its `<<`, and
# the program crashed.
s1 = +"a"
[s1].each.with_index { |q, i| q << i.to_s }
p s1

a2 = [+"b", +"c"]
a2.map.with_index { |q, i| q << "!" }
p a2

s3 = +"d"
[s3].each.each_with_index { |q, i| q << "?" }
p s3

h4 = { k: +"e", j: +"f" }
h4.each_value.with_index { |q, i| q << i.to_s }
p h4

s5 = +"g"
h5 = { k: s5 }
h5.each_value.each_with_index { |q, i| q.concat("#") }
p s5, h5

h6 = { k: "x", j: "y" }
h6.each_value.with_index { |q, i| p [q, i] }
