# `[a, b, c].min` / `.max` on a literal of Integers is the extreme of the
# values, compared in place with no array built. Each element still runs
# once, in order, and an element that may be nil keeps the Array path.
$log = []
def v(x)
  $log << x
  x
end

p [v(3), v(1), v(2)].min, $log
$log.clear
p [v(3), v(1), v(2)].max, $log
p [5].min, [5].max
p [-1, -1, 0].min, [7, 7, 2].max

# the edit-distance step: the smallest of insert, delete, substitute
def lev(s1, s2)
  m = Array.new(s1.length + 1) { Array.new(s2.length + 1, 0) }
  (0..s1.length).each { |i| m[i][0] = i }
  (0..s2.length).each { |j| m[0][j] = j }
  (1..s1.length).each do |i|
    (1..s2.length).each do |j|
      cost = s1[i - 1] == s2[j - 1] ? 0 : 1
      m[i][j] = [m[i][j - 1] + 1, m[i - 1][j] + 1, m[i - 1][j - 1] + cost].min
    end
  end
  m[s1.length][s2.length]
end
p lev("kitten", "sitting"), lev("abcd" * 50, "dcba" * 50)

x = [1, nil][ARGV.size]
begin
  p [x, 2].min
rescue ArgumentError, NoMethodError => e
  p e.class
end
