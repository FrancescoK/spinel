# define_method in an if/unless arm of a Struct block that a literal
# condition selects defines the struct's method
S = Struct.new(:a) do
  if true
    define_method(:x) { a + 1 }
    if 1
      define_method(:y) { a + 2 }
    end
  end
  unless true
    define_method(:never) { 0 }
  else
    define_method(:z) { a + 3 }
  end
  if false
    define_method(:gone) { 0 }
  elsif true
    [:p, :q].each { |n| define_method(n) { n } }
  end
end
s = S.new(1)
p s.x, s.y, s.z, s.p, s.q
p s.respond_to?(:never), s.respond_to?(:gone)
