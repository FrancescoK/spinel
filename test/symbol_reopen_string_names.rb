# A Symbol reopen's own method of a name the String rewrite knows
# (index, <, count, ...) is the call's target; other names keep the
# Symbol-as-text answers, and a user class's method of the name does not
# take a Symbol's call.
class Symbol
  def index(x); "my-index"; end
  def <(o); "my-lt"; end
  def count(x); "my-count"; end
  def [](i); "my-at-#{i}"; end
end

class Box
  def start_with?(x); "box"; end
end

a = :apple
puts a.index("p")
puts(a < :b)
puts a.count("p")
puts a[1]
puts a.start_with?("ap")
puts a.end_with?("le")
p(a <=> :banana)
puts Box.new.start_with?("x")

def in_method(s)
  [s.index("x"), s < :z, s.match?(/pp/)]
end
p in_method(:apple)

[:x, :y].each { |s| puts s.count("x") }
