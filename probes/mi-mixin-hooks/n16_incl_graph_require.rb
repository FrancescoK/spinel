# included: hook added in a required file after the first include
module M; end
class A; include M; end
require_relative "n16_lib/hook"
class B; include M; end
puts "done"
