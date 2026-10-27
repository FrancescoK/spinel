# A prepend in a file with two requires takes effect when the file runs,
# not from the start.
class Foo
  def hi = "foo"
end
puts Foo.new.hi
require_relative "place_prepend_lib" if ARGV.empty?
require_relative "place_prepend_lib" unless ARGV.empty?
puts Foo.new.hi
