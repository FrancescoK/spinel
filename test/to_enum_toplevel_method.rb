# to_enum / enum_for on a top-level method returns a working Enumerator.
def each3
  return to_enum(:each3) unless block_given?
  yield 1; yield 2; yield 3
end
p each3.to_a, each3.map { _1 * 2 }

def pairs
  return enum_for(:pairs) unless block_given?
  yield 1, :a
  yield 2, :b
end
e = pairs
p e.next, e.next
begin
  e.next
rescue StopIteration
  p :stop
end
e.rewind
p e.peek
p pairs.map { |n, s| "#{n}#{s}" }
p pairs.with_index.to_a

def words
  return to_enum(__method__) unless block_given?
  yield "x"; yield "y"
end
p words.first, words.include?("y")
p self.to_enum(:words).to_a
[1].each { p to_enum(:words).to_a }
words { |w| print w }
puts

class C
  include Enumerable
  def each
    return enum_for(:each) unless block_given?
    yield 4; yield 5
  end
end
p C.new.each.to_a, C.new.map { _1 + 1 }, C.new.each.next
