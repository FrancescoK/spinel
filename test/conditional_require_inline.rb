# A require under a condition loads its file only when that branch runs; a
# name computed at run time raises LoadError, so the rescue fallback loads.
if ENV["SPINEL_TEST_NEVER_SET_XYZ"] == "a"
  require_relative "conditional_require_inline/impl_a"
else
  puts "not a"
end
begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "conditional_require_inline/#{$1}/native"
rescue LoadError
  require_relative "conditional_require_inline/nat"
end
p Nat.x
# the same file under both branches of a condition: one definition
if ENV["SPINEL_TEST_NEVER_SET_XYZ"] == "b"
  require_relative "conditional_require_inline/both"
  puts "b"
else
  require_relative "conditional_require_inline/both"
  puts "not b"
end
p Both.v
p Both::Box.new(4).twice
