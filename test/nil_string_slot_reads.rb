# NULL in a String slot is nil to class tests, comparisons, case arms,
# conversion and typed Array searches. An empty String is a different value.
# spinel: gc-minor
x = "value"
x = ARGV.empty? ? nil : "value"
p [String === x, NilClass === x, Object === x, Comparable === x]
p [x == nil, nil == x, x != nil, x === nil, nil === x]
p [x <=> "value", "value" <=> x, x <=> nil, nil <=> x, x <=> x]
p(case x when nil then :nil else :other end)
case x
when String then p :string
when NilClass then p :nilclass
else p :other
end
p [String(x).frozen?, (x in nil), (x in NilClass), (x in String)]
p [String(x), [x].include?(nil), [x].count(nil), [x].include?(""), [x].count("")]

$x = "value"
$x = nil
p(case $x when nil then :nil else :other end)
p [String === $x, String($x)]

def optional_string(z = nil) = z
a = [optional_string("value")]
a << optional_string
a << ""
p [String === a[1], NilClass === a[1]]
p [a.include?(nil), a.member?(nil), a.count(nil), a.index(nil), a.rindex(nil)]
p [a.include?(""), a.count(""), a.index(""), a.rindex("")]
needle = [nil, "value"][ARGV.size]
p [a.include?(needle), a.count(needle), a.index(needle), a.rindex(needle)]
p [a.include?(:value), a.count(:value), a.index(:value)]
p [a[1] <=> a[2], a[1] == a[2], a[1] === a[2]]
p [String(optional_string), String(optional_string("value"))]
x = "value"
p [String === x, NilClass === x, x === nil, x <=> "value", String(x)]

b = [optional_string("value"), optional_string, ""]
p b.delete(nil), b
b << optional_string
p b.delete(needle), b
# Both arguments run once, in receiver-first order, across allocation.
def left_string
  puts "left"
  ["value"][ARGV.size + 1]
end
def right_string
  puts "right"
  "value" * 2
end
p left_string <=> right_string
