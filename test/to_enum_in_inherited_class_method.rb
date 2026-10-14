# A `to_enum` in a class method whose receiving class is known only at run
# time (here, an inherited one) builds an enumerator that runs the method on
# that class.

class Base
  A = 1
  def self.each
    return to_enum(:each) unless block_given?
    constants.each { |name| yield name }
  end

  def self.pairs(prefix)
    return to_enum(:pairs, prefix) unless block_given?
    constants.each { |name| yield "#{prefix}#{name}", const_get(name) }
  end
end

class Sub < Base
  B = 2
end

p Base.each.to_a
p Sub.each.to_a
p Sub.pairs("x").to_a
e = Sub.each
p e.next
p e.next
