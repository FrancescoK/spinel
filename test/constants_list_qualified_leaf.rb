# Module#constants lists a constant or a nested class by the name it was
# written with, also when its leaf is another module's too (spinel keys
# those by a qualified internal name). The names it lists read back
# through const_get. The listings are sorted: CRuby does not list
# constants in the order they were assigned.

module Outer
  module UP
    def self.all(name)
      constants.grep(/#{name}/).sort.flat_map(&method(:const_get))
    end
    V1_A = [1].freeze
    V1_B = [2].freeze
    All = all(/^V1_/)
    class Inner; end
  end
  module Other
    All = [9]
    class Inner; end
  end
end
p Outer::UP.constants.sort
p Outer::Other.constants.sort
p Outer::UP::All
name = ARGV.size > 3 ? "x" : "All"
p Outer::UP.const_get(name)
p Outer::Other.const_get(name)
p Outer::UP.const_get(ARGV.size > 3 ? "x" : "Inner")
p Outer::Other.constants.sort.map { |n| Outer::Other.const_get(n) }
