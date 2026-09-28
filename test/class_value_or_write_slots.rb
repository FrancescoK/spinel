# `@k ||= SomeClass` memoizes the class, as a local `k ||= SomeClass` does:
# an unset Class slot is nil, not the program's first class, in an instance
# ivar, a class-level ivar and a global, and `&&=` leaves a nil slot nil.
class Base
  def klass = (@k ||= String)
  def self.dk
    @dk ||= (ARGV.empty? ? Array : Hash)
  end
  def and_set
    @a &&= Array
    @a
  end
  def reset(v)
    @k = v
    klass
  end
end

b = Base.new
p b.klass, b.klass == String, b.klass.equal?(b.klass)
p Base.dk, Base.dk
p b.and_set
p b.reset(Integer), b.reset(nil)

$g ||= Hash
$g ||= Array
p $g
j ||= Symbol
p j
