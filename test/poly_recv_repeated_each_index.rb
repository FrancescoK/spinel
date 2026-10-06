# repeated_permutation / repeated_combination and each_index on a boxed
# Array (one a variable may also hold an Integer in) and on a general
# Array. The repeated pair's block form had no arm for the boxed receiver
# and raised NoMethodError, as did a general Array's blockless
# repeated_permutation; each_index's block form ran but answered nil, not
# the receiver.
a = [3, 1]
a = 5 if ARGV.size > 3
p(a.repeated_permutation(1) { |q| p q })
p(a.repeated_combination(2) { |q| p q })
p(a.each_index { |i| p i })
x = a.each_index { |i| i }
p x
p a.repeated_permutation(1).to_a
p a.repeated_combination(2).to_a

g = [3, nil]
p g.repeated_permutation(1).to_a
p g.repeated_permutation(2).size
p(g.repeated_permutation(1) { |q| p q })
p(g.each_index { |i| p i })

class N
  def initialize = (@a = [3, 1])
  def run
    instance_variable_set(:@a, @a + [nil]) if @a.size > 9
    @a = 7 if @a.size > 9
    c = @a.repeated_permutation(1) { |q| q }
    p c
  end
end
N.new.run
