class Base
  def greet(x) = "base #{x}"
end

module Loud
  def greet(x) = super.upcase
end

class Greeter < Base
  include Loud
  def greet(x) = super + "!"
end

p Greeter.new.greet("hi")

module Init
  def initialize(*)
    wrap { super }
  end

  def wrap = yield
end

class Vehicle
  include Init
  attr_reader :log

  def initialize
    @log = [:init]
    super()
  end
end

p Vehicle.new.log

class Bare
  include Init
end

p Bare.new.class
begin
  Bare.new(1)
rescue ArgumentError => e
  p e.message
end
