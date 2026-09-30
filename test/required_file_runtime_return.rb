$skip = true
require_relative "required_file_runtime_return_lib/gated"
puts "main continues"
$skip = false
require_relative "required_file_runtime_return_lib/kept"
p Kept.new.v
require_relative "required_file_runtime_return_lib/outer"
puts "main after outer"
