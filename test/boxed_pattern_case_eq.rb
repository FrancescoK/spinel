# all?, any?, none? and one? with a pattern test `pattern === element`. A
# pattern read out of a mixed Array (a Class, a Range, a Regexp) was compared
# by == instead, so `[1, 2].any?([Integer, :x][k])` answered false; with a
# block the call ran the block, which CRuby ignores when a pattern is given.
# count still compares by ==.

def t(k)
  log = []
  h = {1 => 2, "a" => 3}
  p [1, 2].any?([Integer, :x][k]), [1, 2].all?([1..2, :x][k]), [1, 2].any?([/a/, :x][k])
  p %w[ab cd].any?([/a/, :x][k]), [1, "a", 2].one?([String, :x][k]), [1, 2, 3].none?([4..9, :x][k])
  p h.any?([Array, :x][k]), h.all?([Array, :x][k]), h.none?([Array, :x][k]), h.one?([[1, 2], :x][k])
  p h.count([[1, 2], :x][k]), [1, 2, 1].count([1, :x][k])
  p({1 => 2}.one?([[1, 2], :x][k]) { |b| log << b; true })
  p([1, 2].any?([Integer, :x][k]) { |b| log << b; false })
  p([1, 2].all?([1..2, :x][k]) { |b| log << b; false })
  p log
end
t(ARGV.size)
