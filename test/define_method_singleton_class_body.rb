# define_method in a `class << self` / `class << Const` body defines a class method
class Sc
  @base = 10
  class << self
    define_method(:sw) { 11 }
    define_method(:sx) { |a| a + sw }
    define_method(:sk) { |a, k: 2| a * k }
    define_method("ss") { self.name }
    if true
      define_method(:cond) { :c }
    end
  end
  def inst = self.class.sw
end
class Other; end
class << Other
  define_method(:oth) { |x = 3| x * 2 }
end
module Mo
  class << self
    define_method(:mm) { :mm }
  end
end
class Sub < Sc; end
p Sc.sw, Sc.sx(1), Sc.sk(3), Sc.sk(3, k: 4), Sc.ss, Sc.new.inst
p Other.oth, Other.oth(5), Mo.mm, Sub.sw, Sub.sx(2)
p Sc.respond_to?(:sw), Sc.new.respond_to?(:sw)
begin; Sc.new.sw; rescue NoMethodError => e; p e.class; end
begin; Sc.sx; rescue ArgumentError => e; p e.message; end
p Sc.cond
