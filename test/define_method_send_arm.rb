# A forwarding method's runtime-name send, in a program that spells
# :define_method somewhere: the send's dispatch has a define_method arm.
class Wrap
  def initialize(obj) = @obj = obj
  def fwd(m, *args, &block)
    @obj.__send__(m, *args, &block)
  end
end
class K
  def hi = "hi"
end
p K.respond_to?(:define_method, true)
p Wrap.new("abc").fwd(:upcase)
p Wrap.new(K.new).fwd(:hi)
