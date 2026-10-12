# Class#method_defined? and its visibility forms with a name and a class only
# the run time knows, answered as CRuby answers them.
class Animal
  attr_reader :name
  attr_accessor :age

  def speak; end

  protected

  def secret; end

  private

  def hidden; end
end

class Dog < Animal
  def fetch; end
end

names = %w[speak secret hidden fetch name age age= initialize to_s missing]
[Animal, Dog].each do |klass|
  names.each do |n|
    sym = n.to_sym
    puts [klass, n,
          klass.method_defined?(n), klass.public_method_defined?(sym),
          klass.protected_method_defined?(n), klass.private_method_defined?(sym),
          klass.method_defined?(n, false), klass.public_method_defined?(sym, false)].inspect
  end
end
