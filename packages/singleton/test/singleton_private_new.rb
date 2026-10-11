# A Singleton class's `new` and `allocate` are private, and its instance
# refuses `dup` and `clone` with a TypeError naming the class.
require "singleton"

class Registry
  include Singleton
end

begin
  Registry.new
rescue NoMethodError
  puts "new is private"
end
begin
  Registry.allocate
rescue NoMethodError
  puts "allocate is private"
end
begin
  Registry.instance.dup
rescue TypeError => e
  puts e.message
end
begin
  Registry.instance.clone
rescue TypeError => e
  puts e.message
end
