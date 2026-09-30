require_relative "require_modifier_condition_lib/skipped" if ENV["SPINEL_TEST_NEVER_SET_XYZ"]
require_relative "require_modifier_condition_lib/loaded" unless ENV["SPINEL_TEST_NEVER_SET_XYZ"] # note
p __LINE__
if ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil?
  require_relative "require_modifier_condition_lib/nested" if ENV["SPINEL_TEST_NEVER_SET_XYZ"]
  puts "branch continues"
end
p __LINE__
p require_relative("require_modifier_condition_lib/skipped")
p Skipped.new.name
require_relative "require_modifier_condition_lib/continued" if ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil? &&
  true
require_relative "require_modifier_condition_lib/nested" if ENV["SPINEL;TEST_NEVER"] # never; ends with.
