require_relative "inner"
puts "outer continues"
return unless ENV["SPINEL_TEST_NEVER_SET_XYZ"]
puts "outer tail (must not run)"
