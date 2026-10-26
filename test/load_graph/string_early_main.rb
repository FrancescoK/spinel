# A call in a required file runs before the entry's later String reopening
# defines the method: it reaches the builtin.
require_relative "string_early_lib"
class String
  def each_line
    yield "custom"
    self
  end
end
y = []
"ab".each_line { |l| y << l }
p y
