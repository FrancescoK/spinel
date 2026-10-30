# poly_poly_hash_delete_in_place shape: @a == o.a with @a nil
class K
  attr_reader :a
  def initialize(a); @a = a; end
  def eql?(o); o.is_a?(K) && @a == o.a; end
end
p K.new(1).eql?(K.new(1))
p K.new(nil).eql?(K.new(nil))
p K.new(nil).eql?(K.new(2))
