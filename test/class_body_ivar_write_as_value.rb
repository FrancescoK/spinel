# In a class or module body an ivar write is the class's own ivar, also
# where its value is used: as an argument, in an Array, in a String, and
# for ||=, &&= and an operator write.
class Config
  p(@level = 1)
  p(@name ||= "config")
  p(@level += 2)
  p(@name &&= "renamed")
  list = [(@tag = :t), (@count = 0)]
  p list
  puts "count=#{@count += 5}"
  def self.state = [@level, @name, @tag, @count]
end

module Registry
  p(@entries ||= [])
  p(@size = @entries.size)
  def self.state = [@entries, @size]
end

class Child < Config
  p(@level = 10)
end

p Config.state, Registry.state
p Child.instance_variable_get(:@level)
