# A local every write of which is an empty `[]` takes Array's methods,
# blocks and all, and a Hash with typed values answers compact!. The
# local was typed the boxed Array only after the analysis converged, so
# the calls on it had no type and raised "undefined method ... for an
# instance of Array" (CRuby's NoMethodError text for a method Array has).
# A typed-value Hash holds no nil, so compact! is a no-op answering nil.

a = []
p a.min_by { |x| x }
p a.max_by { |x| x }
p a.minmax_by { |x| x }
p a.tally
p a.rfind { |x| x == 1 }
p a.take_while { |x| x }
p a.drop_while { |x| x }
p a.flat_map { |x| [x] }
p a.filter_map { |x| x }
p a.find_all { |x| true }
p a.partition { |x| x }
p a.grep(1)
p a.grep_v(1)
p a.group_by { |x| x }
p a.each_with_object([]) { |x, acc| acc << x }
p a.lazy.map { |x| x }.to_a
p a.each_slice(2).to_a
p a.sum
p a.zip([1])

b = []
b[2] = 3
p b.rfind { |x| x == 3 }
p b.filter_map { |x| x }
c = []
x, c = 1, [7]
p c.min_by { |v| v }

h = {"a" => 1}
p h.compact!
p h
i = {1 => "x"}
p i.compact!
j = {a: 1}
p j.compact!.nil?
k = {"a" => 2}.freeze
begin
  k.compact!
rescue => e
  p e.class
end
