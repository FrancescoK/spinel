require_relative "required_file_return_sugar_lines_lib/folded"
p [1, 2].map(
  &:to_s
)
require_relative "required_file_return_sugar_lines_lib/runtime"
puts "main continues"
