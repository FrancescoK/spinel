class Object
  def ivd = instance_variable_defined?(:@x)
end
class B; end
b = B.new
p b.ivd
b.instance_variable_set(:@x, 9)
p b.ivd, b.instance_variable_get(:@x)
p B.new.ivd
p [B.new, 1].map(&:ivd)
