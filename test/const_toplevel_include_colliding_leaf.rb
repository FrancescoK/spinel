# A top-level `include` makes the module's constants Object's, so a bare read
# at the top level finds them, also when another namespace defines a constant
# of the same name (here Parser::Decimal beside Parser::Acceptables::Decimal).
class Parser
  Decimal = /\A\d+\z/
  module Acceptables
    Decimal = Parser::Decimal
    Octal = /\A[0-7]+\z/
  end
end

include Parser::Acceptables

p Decimal
p Octal
p Parser::Decimal.equal?(Decimal)
