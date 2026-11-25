# A call through self.class or to a method a program adds to Class asks
# whether its target yields the same way its splice binds it: a yielding
# class method whose result is nil, called through self.class, and a
# yielding Class method called on a builtin class.
class B
  def self.check
    puts "ok" if yield
    nil
  end

  def go
    [1, 2].each { |i| self.class.check { i > 1 } }
    p self.class.check { true }
    a = [1].map { self.class.check { true } }
    p a
    p(self.class.check { true }, self.class.check { false })
  end
end

class D < B
end

B.new.go
D.new.go

class Class
  def say
    puts "#{name}:#{yield}"
    nil
  end
end

p Integer.say { 1 }
r = [1, 2].map { |i| String.say { i } }
p r
