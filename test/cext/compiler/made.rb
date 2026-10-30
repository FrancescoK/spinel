# frozen_string_literal: true
require_relative 'made'

# an object C makes, of a class the program never builds with `new`, renders
# and converts through its C methods when it is boxed beside other values
made = CextMade.make(2)
items = [made, 1]
p items
puts "#{items.first}"
puts items.inspect
puts [10, 20, 30, 40][items.first]
puts Integer(items.first)
