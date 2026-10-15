# pp and pretty_inspect lay a value out as CRuby's pp does: on one line when
# it fits in 79 columns, broken across lines when it does not.
require "pp"

Point = Struct.new(:x, :y)
Coord = Data.define(:lat, :lng)

pp 1, 2.5, :sym, nil, true
pp [1, [2, [3, nil]], "s"]
pp({name: "a" * 30, items: (1..20).to_a, nested: {k: "v" * 40, list: %w[alpha beta gamma delta epsilon]}})
pp({"string key" => 1, :"quoted-sym" => 2, sym: [3, 4], 5 => nil, :a? => 6})
pp Point.new(1, 2)
pp Point.new("x" * 40, "y" * 40)
pp Coord.new(lat: 1.5, lng: -2.25)
pp (1..10), (1...), ("a".."z")
pp "line one\nline two\nline three"
a = [1, 2]
a << a
pp a
h = {k: 1}
h[:self] = h
pp h
x = pp(42)
p x
y = pp(1, 2)
p y
p pp
print [1, 2, 3].pretty_inspect
print (1..30).to_a.pretty_inspect
