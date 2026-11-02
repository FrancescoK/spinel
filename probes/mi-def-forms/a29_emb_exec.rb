class Helper
  def two(a, b) = [self.class, a, b]
end
o = Helper.new
p String.class_exec(1, 2, &o.method(:two))
p 5.instance_exec(:x, :y, &o.method(:two))
