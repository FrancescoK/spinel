# The header naming a missing superclass is in a required file: the
# NameError rises at the header, in that file's top level, as it runs.
# spinel: exit 1
module Views
  class Base
  end
end
puts "before"
require_relative "superclass_missing_lib"
puts "after"
