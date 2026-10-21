# A Class-typed dispatch and a boxed one keep their method union recorded.
class First
  def self.pattern = 3
end
class Second
  def self.pattern = 4
end
[First, Second].each { |klass| p klass.pattern }
[First, Second, nil].each { |klass| p klass.pattern if klass }
