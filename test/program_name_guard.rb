# `__FILE__ == $0` (and its spellings) is true in the entry script of a
# compiled binary and false in a required file, while `$0` stays argv[0].
require_relative "program_name_guard_lib/helper"

if __FILE__ == $0
  puts "file == $0"
end
if $0 == __FILE__
  puts "$0 == file"
end
if __FILE__ == $PROGRAM_NAME
  puts "file == $PROGRAM_NAME"
end
if File.expand_path(__FILE__) == File.expand_path($0)
  puts "expand_path"
end
unless __FILE__ == $0
  puts "unless (must not run)"
end
puts "not main" if __FILE__ != $0
main = __FILE__ == $0
p main
p Helper.guards
p $0.is_a?(String)
