# Hash#inspect writes a Symbol key as a label (`a: 1`) only where the name
# can be written as one: an identifier, with an optional trailing ? or !.
# Any other name is quoted like a String: an attribute writer ("a="), an
# instance, class or global variable's name, an operator, and a name with
# other characters.

h = {}; [:a, :A, :a?, :a!, :a=, :@a, :@@a, :$a, :+, :*, :[], :"age=1.1", :"foo bar", :_x, :"9a", :"a-b", :"é", :"!", :<=>, :"", :nil, :if, :"a?b"].each { |k| h[k] = 1 }
puts h.inspect
x = [h, 1][ARGV.size]
p x
p({"*": [:*]})
p({a: 1, "b": 2, :"c d" => 3})
p({x: {"+": [:+]}, "y=": :"y="})
