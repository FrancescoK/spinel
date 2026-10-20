# A class method to_s or inspect a class defines of its own prints the
# class: puts, interpolation and to_s read to_s, while p, inspect and an
# Array's or a Hash's inspect read inspect (Module#inspect is not to_s's
# alias to a Ruby override). Every form printed the class's name, and a
# class was no argument print took.

module Store
  def self.to_s = "Store as text"
end

class Base
  def self.inspect = "#<#{name} family>"
end

class Child < Base
end

class Plain
end

puts Store
puts "in #{Store}"
p Store
p Base
p Child
puts Child
p [Store, Base, Plain]
p({ Child => 1 })
puts [Store, Plain]
[Store, Base, Child, Plain].each do |k|
  puts k
  p k
  puts "#{k}/#{k.to_s}/#{k.inspect}"
end
print Store, " ", Plain, "\n"
k = ARGV.empty? ? Store : Plain
print k, "\n"
