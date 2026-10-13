# a class whose own #at forwards to its Array's: where the value turns out
# a builtin, the dispatch's builtin arm is Array#at -- the index read, nil
# past the end, and NoMethodError for a Hash, which has #[] but no #at

class C
  def initialize(a) = (@a = a)
  def to_a = @a
  def at(*x) = to_a.at(x[0])
end
C.new([1, 2])
C.new("s")
p C.new([[7, 8], 66]).at(1)
p C.new([[7, 8], 66]).at(5)
p C.new([1, 2]).at(-1)
begin
  C.new({1 => 2}).at(1)
rescue NoMethodError => e
  puts e.message
end
