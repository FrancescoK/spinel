# frozen_string_literal: true

# Unreachable dependencies need not exist, even with --require-gate.
if false
  require "spinel_missing_unreachable_library"
  require_relative "require_unreachable/missing"
  local = 1
end
p defined?(local)

unless true
  require_relative "require_unreachable/missing"
end
require_relative "require_unreachable/missing" if nil
require "spinel_missing_unreachable_library" unless true
require_relative(
  "require_unreachable/missing"
) if false

if true
  puts "if"
else
  require_relative "require_unreachable/missing"
end
unless false
  puts "unless"
else
  require_relative "require_unreachable/missing"
end
unless nil
  puts "nil"
else
  require_relative "require_unreachable/missing"
end

if (false)
  require_relative("require_unreachable/missing")
elsif nil
  require_relative "require_unreachable/missing"
else
  puts "elsif"
end

# A nested live-looking branch is still unreachable; a dead branch inside
# a runtime condition is also safe to skip.
if false
  if true
    require_relative "require_unreachable/missing"
  end
end
if ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil?
  require_relative "require_unreachable/missing" if false
end

# Skipping a dependency must not mark it loaded or disturb later lines and
# the file's frozen-string pragma. Apply the same rule in required files.
require_relative "require_unreachable/loaded" if false
p __LINE__
p require_relative("require_unreachable/loaded")
p require_relative("require_unreachable/loaded")
p "frozen".frozen?
