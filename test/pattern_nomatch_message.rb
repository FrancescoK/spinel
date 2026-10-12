# A single pattern that fails -- `expr => pat`, or a case/in with one `in`
# and no else -- says why in its NoMatchingPatternError, as CRuby does: the
# subject's inspect, then the check that failed. A case/in of several arms
# names the subject alone. A missing hash key is NoMatchingPatternKeyError.
def t
  yield
  puts "matched"
rescue NoMatchingPatternError => e
  puts "#{e.class}: #{e.message}"
end

def first_int(v)
  case v
  in [Integer => a, String] then a
  end
end

def name_of(v) = (v => {name: String => nm}; nm)

t { [1, 2, 3] => [Integer, Integer] }
t { [1] => [Integer, *rest, String] }
t { [1, 2, 3] => [] }
t { [1, 2] => [Integer, String] }
t { [[1, 2]] => [[a]] }
t { 5 => String }
t { 5 => String | Float }
t { 5 => nil }
t { 1.5 => Integer }
t { :s => :t }
t { "s" => "t" }
t { "abc" => /x/ }
t { 5 => 1..3 }
y = 3
t { 5 => ^y }
t { "x" => [a] }
t { 5 => {a:} }
t { [1] => [*, String, *] }
t { [1, 2] => [*, 1, 2, 3, *] }
t { {a: 1} => {b:} }
t { {a: 1} => {a: String} }
t { {a: 1} => {} }
t { {a: 1, b: 2} => {a: Integer, **nil} }
t { {a: [1, 2]} => {a: [_, String]} }
t { first_int([1, 2]) }
t { first_int("x") }
t { name_of({name: 1}) }
t { name_of({nm: 1}) }
t { case 5; in Integer if false then 1; end }
t { case 5; in String then 1; in Float then 2; end }
t { case [1]; in [] then 1; in [String] then 2; end }
[1, "a", :b, nil].each { |v| t { v => Integer | Float } }
t { [1, 2, 3] => [*, Integer]; puts "ok" }

class Shape; def inspect = "#<#{self.class.name}>"; end
class Square < Shape; end
class Circle < Shape; end
module Round; end
LIMIT = 5
t { Square.new => Circle }
t { Square.new => Shape }
t { Circle.new => Round }
t { 3 => LIMIT }
t { [Square.new] => [Circle] }
t { 7 => Numeric | String }
t { (1..2) => Integer }
t { {"b" => 2} => {**nil} }

# a long inspect survives the message's allocation
big = (1..2000).to_a
begin
  big => [Integer]
rescue NoMatchingPatternError => e
  puts e.message[-50..]
end
