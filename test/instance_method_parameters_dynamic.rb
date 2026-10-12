# Class#instance_method(name).parameters with a class or a name only the run
# time knows, as CRuby answers it (Thor checks a command's arity this way).
class Base
  def run(a, b = 1, *rest, key:, opt: 2, **more, &blk); end
  def bare; end
end

class Child < Base
  def own(x); end
end

[Base, Child].each do |klass|
  %w[run bare].each { |n| p [klass, n, klass.instance_method(n.to_sym).parameters] }
end
k = Child
p k.instance_method("own".to_sym).parameters
begin
  k.instance_method("nope".to_sym).parameters
rescue NameError => e
  puts e.message
end
