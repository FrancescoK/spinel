# Each file's top level runs at its require, once, with locals of its own.
x = "main's x"
$order = []
$order << :main_start
require_relative "shapes"
require_relative "counter"
require_relative "counter"
puts x
puts Counter.total
puts Shape.new(3).area
puts square_of(7)
puts LIMIT
$order << :main_end
p $order
