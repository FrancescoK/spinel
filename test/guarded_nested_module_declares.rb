# `unless defined?(::Outer::Name)` around Name's only declaration is a reload
# guard: on the first load Name is absent and the body runs (#9884).
module Shelf
  unless defined?(::Shelf::VERSION)
    module VERSION
      STRING = "2026.10.0-latest"
      PARTS = STRING.split(".")
      private_constant :PARTS
      MAJOR = PARTS[0].to_i
    end
  end
end
p [Shelf::VERSION::STRING, Shelf::VERSION::MAJOR]

# the relative spelling
module Rack2
  unless defined?(Release)
    class Release
      NAME = "r"
    end
  end
end
p Rack2::Release::NAME

# declared before the guard: the guard skips the second body
module Bin
  module Tag
    WHO = :first
  end
end
module Bin
  unless defined?(::Bin::Tag)
    module Tag
      WHO2 = :second
    end
  end
end
p [Bin::Tag::WHO, Bin::Tag.const_defined?(:WHO2)]
