# An uncaught exception of a class made by Class.new prints the class as it
# shows by then: the constant's name once the class is named, whatever name
# the compiler gave it.
k = Class.new(StandardError)
e = k.new
Foo = k
puts "before"
raise e
