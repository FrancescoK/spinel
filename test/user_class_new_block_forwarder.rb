# A user `self.new` forwarder taking &block (#5409), and one whose class
# shares the program with another class's differently shaped `self.new`
# (#5410, Phlex::SGML): `new(...)` in a class method reaches the class's own
# self.new with its arguments, and the result dispatches on its class.
class Base
  class << self
    def call(...)
      new(...).run
    end
    def new(*a, **k, &block)
      super
    end
  end
  def run = :base
end
class Mid < Base
  def run = :mid
end
p Base.call
p Mid.call

class Other
  def self.new(x) = super()
  def v = :other
end
class SGML
  class << self
    def call(...)
      new(...).call
    end
    def new(*a, **k, &block)
      super
    end
  end
  def initialize(title = "t", x: 1)
    @title = title
    @x = x
  end
  def call = "#{self.class.name}:#{@title}:#{@x}"
end
class Page < SGML
  def call = "page " + super
end
p SGML.call
p Page.call("hi", x: 2)
p Other.new(1).v
