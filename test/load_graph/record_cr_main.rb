# The load record's answers for three shapes (--dump-load-record,
# record_cr_main.rb.load-record): a class_eval block under a rescue
# modifier defines its methods on its receiver; `include A, B` puts A
# nearest the class, so an alias after it takes A's method and a constant
# read after it A's constant; and a method
# defined only under a condition is not known at the end of the load phase
# (`end=`, the answer a query from a method body gets).
class Foo
end
Foo.class_eval do
  def bar = "bar"
end rescue nil
module A
  def who = "A"
  module Kind
    def kind = "A kind"
  end
end
module B
  def who = "B"
  module Kind
    def kind = "B kind"
  end
end
class C
  include A, B
  alias_method :first_who, :who
  include Kind
end
class D
  if ARGV.size > 5
    define_method(:maybe) { 1 }
  end
  def sure = 2
end
puts Foo.new.bar
p C.ancestors.take(3)
puts C.new.first_who
puts C.new.kind
puts D.new.sure
