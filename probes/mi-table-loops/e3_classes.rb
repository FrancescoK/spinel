module Codes
  class Base
    class << self
      attr_reader :code
    end
  end
  Names = { 1 => "One", 2 => "Two" }
  Names.each_pair { |code, name|
    k = Class.new(Base)
    k.instance_variable_set(:@code, code)
    const_set(name, k)
  }
end
p Codes::One.code, Codes::Two.name, Codes::Two.superclass
