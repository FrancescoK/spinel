# In a class method self is the class object, so `self.class` is Class:
# a yielding method a program adds to Class is run on Class, not on the
# class the method belongs to, even where that class has a class method
# of the same name.
class Class
  def say
    puts "#{name}:#{yield}"
    nil
  end
end

class B
  def self.say
    puts "B's own say"
  end

  def self.go
    self.class.say { 1 }
    p self.class.say { 2 }
    r = [3].map { |i| self.class.say { i } }
    p r
    p(self.class.say { 4 }, self.class.name)
  end

  def inst
    self.class.say { 5 }
  end
end

class E
  def self.go
    self.class.say { 6 }
    p self.class.say { 7 }
  end
end

B.go
B.new.inst
E.go
