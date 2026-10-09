# A private class method stays private when the class is a value read out
# of an Array: the dispatch on the class value called it (#8202).
class C
  def self.foo = 1
  private_class_method :foo
  def self.bar = foo + 10
end
class D
  def self.foo = 2
  def self.bar = 20
end
[C, D].each do |k|
  begin
    p k.foo
  rescue NoMethodError => e
    puts e.message
  end
  p k.bar
end
