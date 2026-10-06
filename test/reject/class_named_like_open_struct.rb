# After require "ostruct", CRuby makes a new class App::OpenStruct, and the
# top-level OpenStruct stays the builtin one. Spinel cannot keep the two
# apart, so it refuses.
require "ostruct"

module App
  class OpenStruct
    def hi = "mine"
  end
end

puts App::OpenStruct.new.hi
puts OpenStruct.new(a: 1).a
