# any?, all?, none? and one? with a pattern on an Array, Hash or Range held
# in a mixed Array (a boxed receiver) test each element with pattern ===
# element, as on an unboxed receiver; the pattern is evaluated after the
# receiver, and a value with no such method raises NoMethodError.
a = [[3, 1, "a"], 5][0]
p a.any?(Integer), a.all?(Integer), a.none?(Float), a.one?(String)
p a.any?(1..2), a.none?(3), a.one?(1), a.all?(Comparable), a.any?(nil)
p a.any?, a.all?
h = [{a: 1, b: 2}, 5][0]
p h.any?([:a, 1]), h.all?(Array), h.none?([:b, 2]), h.one?([:z, 0])
r = [(1..5), 5][0]
p r.any?(3), r.all?(Integer), r.none?(9), r.one?(5), r.any?(2..3)
e = [[], 5][0]
p e.any?(1), e.all?(1), e.none?(1), e.one?(1)
s = [[+"ab", +"cd"], 5][0]
p s.all?(/[a-z]/), s.one?(/c/), s.any?("ab")
$log = []
def t(x)
  $log << x.class
  x
end
p t(a).any?(t(Integer)), $log
[nil, 7].each do |v|
  begin
    [v, [1]][0].any?(1)
  rescue NoMethodError => err
    puts err.message
  end
end
