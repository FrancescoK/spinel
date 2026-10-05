# A reflection-created slot records presence separately from an assigned nil.
class K; end
fresh = K.new
p fresh.instance_variable_defined?(:@q)
p fresh.instance_variables
p fresh.inspect.include?("@q=")
x = [K.new, 1][0]
p x.instance_variable_defined?(:@q)
p x.instance_variable_set(:@q, nil)
p x.instance_variable_defined?(:@q)
p x.instance_variables
p x.inspect.include?("@q=nil")
p fresh.instance_variable_defined?(:@q)
p fresh.instance_variables
p fresh.inspect.include?("@q=")
y = K.new
p y.instance_variable_set(:@q, nil)
p y.instance_variable_defined?(:@q)
p y.instance_variables
p y.inspect.include?("@q=nil")
p y.dup.instance_variable_defined?(:@q)
p fresh.dup.instance_variable_defined?(:@q)
fresh.freeze
begin
  fresh.instance_variable_set(:@q, nil)
rescue FrozenError
  puts "frozen"
end
p fresh.instance_variable_defined?(:@q)

p Marshal.load(Marshal.dump(y)).instance_variable_defined?(:@q)
p Marshal.load(Marshal.dump(K.new)).instance_variable_defined?(:@q)

S = Struct.new(:a)
s = [S.new(1), 0][0]
p s.instance_variable_defined?(:@extra)
p s.instance_variable_set(:@extra, nil)
p s.instance_variable_defined?(:@extra)
p S.new(2).instance_variable_defined?(:@extra)
p s.instance_variables
z = [K.new, 0][0]
p z.instance_variable_set(:@q, 7)
p z.instance_variable_defined?(:@q)
p z.instance_variable_set(:@q, nil)
p z.instance_variable_defined?(:@q)
