# A module or class whose name only starts with Enumerable or Set is not a
# reopening of it: ruby/spec's `module EnumerableSpecs` kept builtins/
# enumerable.rb out, so an `include Enumerable` class lost max_by, tally,
# grep and the rest, and a `class Settings` kept Set's implicit require out.
module EnumerableSpecs
  class Empty
    include Enumerable
    def each; end
  end
  class Numerous
    include Enumerable
    def each
      yield 2
      yield 5
      yield 3
    end
  end
end
class Settings
end
e = EnumerableSpecs::Empty.new
p e.max_by { |o| o.nonesuch }, e.min_by { |o| o }, e.tally, e.grep(1), e.cycle.first(2)
n = EnumerableSpecs::Numerous.new
p n.max_by { |x| -x }, n.min_by { |x| -x }, n.minmax_by { |x| x }, n.tally
p n.grep(2..3), n.grep_v(2..3), n.cycle.first(4), n.drop_while { |x| x < 5 }
p n.group_by(&:odd?), n.inject(:+), n.each_with_object([]) { |x, a| a << x }
p Set[1, 2].include?(2), [3, 3].to_set.size
