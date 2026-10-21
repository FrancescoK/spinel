# sort_by with a key that is an object of the program's own class orders by
# that class's `<=>`, as CRuby does, where the call raised NoMethodError for
# `sort_by` on an Array. min_by and max_by already ordered such keys.
class Rank
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(o) = n <=> o.n
end

class Cell
  attr_reader :at
  def initialize(s) = @at = s.split(":").map(&:to_i)
  def <=>(o) = at <=> o.at
end

def cell(s) = Cell.new(s)

words = ["bbb", "a", "cc"]
p words.sort_by { |w| Rank.new(w.size) }
p words.sort_by { |w| Rank.new(-w.size) }.first
p [3, 1, 2].sort_by { |i| Rank.new(i) }
p [:cc, :a].sort_by { |s| Rank.new(s.size) }
p (1..3).sort_by { |i| Rank.new(-i) }
p({ a: 2, b: 1 }.sort_by { |_k, v| Rank.new(v) })
p words.each_with_index.sort_by { |_w, i| Rank.new(-i) }

# a key that a method builds, and one whose `<=>` compares Arrays
p %w[1:10 1:2 1:9].sort_by { |s| cell(s) }
p (%w[2:0 1:10] + ["1:9"]).sort_by { |s| cell(s) }

sorted = %w[3 1 2]
sorted.sort_by! { |s| Cell.new(s) }
p sorted

# a single element is never compared
p [1].sort_by { |i| Object.new }.size

# a pair the key's `<=>` does not order raises CRuby's ArgumentError
class Partial
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(o) = (n == 2 ? nil : n <=> o.n)
end
p [3, 1].sort_by { |i| Partial.new(i) }
begin
  p [3, 2, 1].sort_by { |i| Partial.new(i) }
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
