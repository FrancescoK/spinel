# A loop over a constant Hash that names classes with const_set, run when the
# program is compiled: a table String the loop froze is that same frozen
# String wherever the loop stores it.
module Codes
  class Base
    class << self
      attr_reader :code, :label
    end
  end
  Names = { 1 => "One", 2 => "Two" }
  ByCode = {}
  Names.each { |code, name|
    name.freeze
    klass = Class.new(Base)
    klass.instance_variable_set(:@code, code)
    klass.instance_variable_set(:@label, name)
    const_set(name, klass)
    const_set("NAME_#{code}", name)
    ByCode[code] = klass
  }
end
p Codes::One.code, Codes::Two.label, Codes::One.superclass
p Codes::NAME_2, Codes::NAME_1.frozen?, Codes::NAME_1.equal?(Codes::Names[1])
p Codes::One.label.equal?(Codes::Names[1])
p Codes::ByCode.keys, Codes::ByCode[2].name
