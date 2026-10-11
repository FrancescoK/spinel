# CRuby calls inherited from Class.new, while the new class has no name yet,
# so the hook prints nil. Run at compile time, the loop would define a named
# class instead and the hook would print "M::One". A program with an
# inherited hook keeps its loops, which Spinel refuses.
module M
  class Base
    def self.inherited(k); puts "inherited #{k.name.inspect}"; super; end
  end
  T = { 1 => "One", 2 => "Two" }
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p M::One.superclass
