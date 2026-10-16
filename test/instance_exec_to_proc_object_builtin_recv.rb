class Conv
  def to_proc = proc { |a| [self.class, a] }
end
obj = Conv.new
p "s".instance_exec(5, &obj)
p [1].instance_exec(6, &obj)
