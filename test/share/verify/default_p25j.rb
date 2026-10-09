class A; def initialize = (@x = 0); end
class B; end
A.new
[B.new, A.new].each { |o| o.instance_variable_set(:@x, 1) }
p B.new.inspect.sub(/0x\h+/, ""), B.new.instance_variables, B.new.instance_variable_defined?(:@x)
