# A poly receiver holding an exception whose class has no method of its own
# for the name reaches the reopening nearest its class up its ancestry: a user
# subclass two levels under the reopened builtin, a builtin never reopened.
class StandardError
  def tag = "SE:#{message}"
end
class IndexError
  def tag = "IX:#{message}"
end
class RuntimeError
  def rt(n) = "RT#{n}:#{message}"
end
class MyKey < KeyError; end
class MyKey2 < MyKey
  def tag = "MK2:" + super
end
class MyArg < ArgumentError; end
class Plain
  def tag = "plain"
end
xs = [MyKey.new("a"), MyKey2.new("b"), MyArg.new("c"), StopIteration.new("d"), Plain.new, RuntimeError.new("e"), "s", 7]
xs.each { |x| puts(x.respond_to?(:tag) ? x.tag : "no") }
xs.each { |x| puts(x.respond_to?(:rt) ? x.rt(1) : "no") }
xs.each { |x| begin; puts x.rt(2); rescue NoMethodError => e; puts "NME"; end }
