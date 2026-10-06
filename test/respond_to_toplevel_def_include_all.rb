# A top-level def is a private method of Object: every receiver answers it
# to respond_to?(name, true). It read false.
def foo = 1
class K; end
class R
  def respond_to?(m, all = false) = :own
end
p 5.respond_to?(:foo, true), "s".respond_to?(:foo, true), K.new.respond_to?(:foo, true)
p 5.respond_to?(:foo), K.new.respond_to?(:foo), [1].respond_to?(:foo, true), nil.respond_to?(:foo, true)
p R.new.respond_to?(:foo, true)
p 5.respond_to?(:bar, true)
