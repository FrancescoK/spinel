# Many classes exercise Comparable membership through the runtime hook.
class FallbackOrder
  def <=>(other) = 0
end
class Fallback0 < FallbackOrder; end
class Fallback1 < FallbackOrder; end
class Fallback2 < FallbackOrder; end
class Fallback3 < FallbackOrder; end
class Fallback4 < FallbackOrder; end
class Fallback5 < FallbackOrder; end
class Fallback6 < FallbackOrder; end
class Fallback7 < FallbackOrder; end
class Fallback8 < FallbackOrder; end
class Fallback9 < FallbackOrder; end
class Fallback10 < FallbackOrder; end
class Fallback11 < FallbackOrder; end
class Fallback12 < FallbackOrder; end
class Fallback13 < FallbackOrder; end
class Fallback14 < FallbackOrder; end
class Fallback15 < FallbackOrder; end
class Fallback16 < FallbackOrder; end
class FallbackGood < FallbackOrder; include Comparable; end
xs = [Fallback0.new, Fallback1.new, Fallback2.new, Fallback3.new, Fallback4.new, Fallback5.new, Fallback6.new, Fallback7.new, Fallback8.new, Fallback9.new, Fallback10.new, Fallback11.new, Fallback12.new, Fallback13.new, Fallback14.new, Fallback15.new, Fallback16.new, FallbackGood.new]
xs.each do |x|
  begin; p(x < x); rescue NoMethodError => e; puts e.message; end
  begin; p x.between?(x, x); rescue NoMethodError => e; p e.class; end
  begin; p x.clamp(x, x).equal?(x); rescue NoMethodError => e; p e.class; end
end
