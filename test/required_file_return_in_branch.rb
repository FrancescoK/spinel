if ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil?
  require_relative "required_file_return_in_branch_lib/folded"
  puts "branch after folded"
  require_relative "required_file_return_in_branch_lib/runtime"
  puts "branch after runtime"
end
puts "main continues"
p Picker.new.pick(1), Picker.new.pick(2)
