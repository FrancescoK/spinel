# singleton_class.define_method in a class or module body defines a class method
class Sc
  singleton_class.define_method(:sz) { 13 }
  self.singleton_class.define_method(:sa) { |a| a + sz }
  singleton_class.define_method("sb") { |a = 4| a * 2 }
end
module Mo
  singleton_class.define_method(:mz) { :mz }
end
class Sub < Sc; end
p Sc.sz, Sc.sa(1), Sc.sb, Sc.sb(1), Mo.mz, Sub.sa(2)
p Sc.respond_to?(:sz), Sc.new.respond_to?(:sz)
begin; Sc.sa; rescue ArgumentError => e; p e.message; end
