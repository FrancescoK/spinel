# A genuine Array reaching a poly dispatch because a user class (here Set,
# from the bundled set.rb) owns `flatten` is still flattened by the builtin
# arm; it raised NoMethodError naming Array.
require "set"
def f(array)
  raise "x" unless array.is_a? Array
  if array[0].is_a? Array
    array = array.flatten
  end
  array
end
p f([[1, 2], [3, 4]])
p f([1, 2.5])
x = rand > 2 ? 5 : [[1, 2]]
p f(x)
p Set[Set[1], 2].flatten.size
