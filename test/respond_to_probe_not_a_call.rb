# A method that only respond_to? names is never called: respond_to? asks
# whether the receiver answers it, and the analysis-only probe call it is
# typed through is not a call. The probe made the method reachable, so it was
# emitted with poly parameters, and a refusal in its body (an eval of a
# runtime string) stopped the build of a program that never runs it.
class Conf
  attr_writer :name
  def initialize = @level = 1
  def level = @level
  def level=(v)
    @level = eval(v)
  end
  def reset(v) = eval(v)
  def secret=(v)
    @secret = eval(v)
  end
  private :secret=
end

c = Conf.new
p c.level
p c.respond_to?(:level=)
p c.respond_to?(:reset)
p c.respond_to?(:name=)
p c.respond_to?(:secret=)
p c.respond_to?(:secret=, true)
p c.respond_to?(:missing=)

# class methods: the setter writes a typed class variable
class Store
  @@quiet = false
  def self.quiet = @@quiet
  def self.quiet=(v)
    @@quiet = eval(v)
  end
end
p Store.quiet
p Store.respond_to?(:quiet=)
p Store.respond_to?(:loud=)

# a receiver of either class, through a boxed value
class Other
  def level=(v)
    eval(v)
  end
end
[Conf.new, Other.new, 1].each { |o| p o.respond_to?(:level=) }

# a setter both named and called is still emitted
class Live
  attr_reader :v
  def v=(x)
    @v = x * 2
  end
end
l = Live.new
p l.respond_to?(:v=)
l.v = 21
p l.v
