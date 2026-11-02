module Codes
  class Base; end
  Names = { 1 => "One" }
  Names.each { |code, name| const_set(name, Class.new(Base)) }
  class Base
    def self.inherited(k) = puts("inherited")
  end
  class Two < Base; end
end
p Codes::One.superclass
