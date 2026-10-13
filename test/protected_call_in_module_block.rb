# A module's protected method called on another instance from inside the
# module's own method -- in a block there too -- is allowed when the
# receiver's class includes the module (self is an instance of an includer),
# whether the receiver is typed or boxed; from outside it stays refused.
module D
  def each_n(&block)
    visit(&block)
    self
  end

  def peek(o) = [o].map { |x| x.secret }

  protected

  def visit(&block)
    @c.each do |ch|
      next unless ch.is_a?(Base)

      yield ch
      ch.visit(&block)
    end
  end

  def secret = :secret
end

class Base
  def initialize(c) = (@c = c)
end

class N < Base
  include D
end

class Other
  def secret = :other
  protected :secret
end

N.new([N.new([N.new([])]), 1]).each_n { |x| p x.class }
p N.new([]).peek(N.new([]))
begin
  N.new([]).secret
rescue NoMethodError => e
  puts e.message
end
begin
  N.new([]).peek(Other.new)
rescue NoMethodError => e
  puts e.message
end
