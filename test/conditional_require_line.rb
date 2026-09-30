if ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil?
  require_relative "conditional_require_line_lib/helper"
end
p __LINE__
unless ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil?
  require_relative "conditional_require_line_lib/other"
end
p __LINE__
