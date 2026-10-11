# const_set replaces a constant that already holds a class (CRuby warns and
# M::One becomes the new class, without hi). Run at compile time as a class
# definition, the loop would reopen the old class instead. A name the
# program defines anywhere else keeps the loop, which Spinel
# refuses.
module M
  class Base; end
  class One; def hi; "old"; end; end
  T = { 1 => "One" }
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p M::One.superclass, M::One.new.respond_to?(:hi)
