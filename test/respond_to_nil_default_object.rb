# respond_to? on a parameter that defaults to nil, and receives an object
# of a class defining the method in other calls, answers for nil when it
# holds nil: false for the class's own methods, true for nil's own surface.
class Host
  def on_write = 1
  def to_a = [1]
  private def secret = 2
end

def check(host = nil) = host.respond_to?(:on_write)
def kcheck(host: nil) = host.respond_to?(:on_write)
def nilm(host = nil) = host.respond_to?(:to_a)
def uni(host = nil) = host.respond_to?(:inspect)
def priv(host = nil) = host.respond_to?(:secret, true)
def miss(host = nil) = host.respond_to?(:nope)
def rat(host = nil) = host.respond_to?(:rationalize)
def init(host = nil) = host.respond_to?(:initialize, true)

p check(Host.new), check, kcheck(host: Host.new), kcheck
p nilm(Host.new), nilm, uni(Host.new), uni
p priv(Host.new), priv, miss(Host.new), miss
p rat(Host.new), rat, init(Host.new), init
h = Host.new
p h.respond_to?(:on_write)
class Bus
  def initialize(host: nil)
    @n = host.respond_to?(:on_write) ? host.on_write : 0
  end
  attr_reader :n
end
p Bus.new.n, Bus.new(host: Host.new).n
class PubInit
  def initialize(x) = @x = x
  public :initialize
end
class OnlyPub
  public :initialize
end
class PlainInit
  def initialize(x) = @x = x
end
p PubInit.new(1).respond_to?(:initialize), OnlyPub.new.respond_to?(:initialize)
p PlainInit.new(1).respond_to?(:initialize), PlainInit.new(1).respond_to?(:initialize, true)
def pubinit(host = nil) = host.respond_to?(:initialize)
def pubinit_all(host = nil) = host.respond_to?(:initialize, true)
p pubinit(PubInit.new(1)), pubinit, pubinit_all(PubInit.new(1)), pubinit_all
