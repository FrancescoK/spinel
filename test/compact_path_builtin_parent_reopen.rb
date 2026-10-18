# A compact header through another one under a builtin (`module
# Regexp::Expression::EscapeSequence` after `module Regexp::Expression`)
# reopens the module that body holds, so the constants written there are
# read bare inside it and by the full path, also when their leaves collide
# with other constants and classes of the program.

module Regexp::Expression
  class Base
    def kind = :base
  end
  module EscapeSequence
    Base = Class.new(Regexp::Expression::Base)
    Literal = Class.new(Base)
    Hex = Class.new(Base)
  end
end
module Regexp::Expression::EscapeSequence
  Literal.class_eval { def codepoint; 1 end }
  Hex.class_eval { def codepoint; 2 end }
end
Regexp::Expression::EscapeSequence::Base.class_eval do
  def char = codepoint.chr
end
module Other
  class Base; end
  Literal = 5
end
p Regexp::Expression::EscapeSequence::Literal.new.codepoint
p Regexp::Expression::EscapeSequence::Hex.new.kind
p Other::Literal
