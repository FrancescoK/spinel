# Symbol#eql? and #equal? compare by identity with a Symbol, a boxed value
# (true only for the same Symbol) and a value of any other kind (false).
def eq(x) = :a.eql?(x)
def same(x) = :a.equal?(x)
p eq(:a), eq(:b), eq(1), eq("a"), eq(nil)
p same(:a), same(:b), same(1), same("a")
p :a.eql?(:a), :a.eql?(:b), :a.eql?("a"), :a.eql?(1)
p :a.equal?(:a), :a.equal?(:b), :a.equal?(2.0)
