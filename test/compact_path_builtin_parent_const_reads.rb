# A compact header under a builtin (`module Regexp::Syntax`, `class
# Regexp::Syntax::V1 < Regexp::Syntax::Base`) opens a body whose constants
# are read through the path as written. When their leaves collide with
# other constants or classes of the program, the reads still find them:
# by the full path, and through the superclass and the included module the
# headers name by such paths.

module Regexp::Syntax
  module Token
    module Literal
      All = %i[literal].freeze
    end

    module UnicodeProperty
      V1_9_3 = %i[age=1.1 age=2.0].freeze
      All = V1_9_3
    end

    module Lit
      V1_9_3 = %i[other].freeze
    end
  end

  class Base
    include Regexp::Syntax::Token
  end
end

module Regexp::Syntax
  module Token
    All = (Literal::All + UnicodeProperty::All).freeze
  end
end

class Regexp::Syntax::V1_9_1 < Regexp::Syntax::Base
  PROPS = UnicodeProperty::V1_9_3
end

class Regexp::Syntax::V1_9_3 < Regexp::Syntax::V1_9_1
  PROPS = UnicodeProperty::V1_9_3 + Lit::V1_9_3
end

class String::Report
  All = %i[report].freeze
end

p Regexp::Syntax::Token::All
p Regexp::Syntax::Token::Literal::All
p Regexp::Syntax::Token::UnicodeProperty::All
p Regexp::Syntax::V1_9_1::PROPS
p Regexp::Syntax::V1_9_3::PROPS
p String::Report::All

# an enclosing body's own Regexp comes first, as Ruby's lexical lookup
# finds it
module Shadow
  module Regexp
    module Syntax
      module Token
        All = %i[shadow].freeze
      end
    end
  end

  def self.read = Regexp::Syntax::Token::All
end
p Shadow.read
p Regexp::Syntax::Token::All
