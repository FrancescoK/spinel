# In a module's singleton method, self is the module, so method(:const_get)
# and method(:const_defined?) are Module's, bound to it. regexp_parser
# collects its Unicode property lists this way. They built a Method with no
# target, which raised NoMethodError for an instance of Object when called.
module Outer
  module Props
    Age_V1 = %i[a b].freeze
    Age_V2 = %i[c].freeze
    Other = %i[z].freeze

    def self.all(name)
      constants.grep(/#{name}/).sort.flat_map(&method(:const_get)).freeze
    end

    def self.has(names) = names.map(&method(:const_defined?))
    def self.values = constants.sort.map { |n| method(:const_get).call(n) }
  end
end

p Outer::Props.all("Age")
p Outer::Props.has(%i[Other Nope])
p Outer::Props.values
