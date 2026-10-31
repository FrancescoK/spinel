# The class-body macro form declines: a block that passes a value of the
# macro's frame as a block argument (`&m`), which a written `&:upcase` would
# spell as a block of its own.
class Base
  def self.prop(n, m) = define_method(n) { |xs| xs.map(&m) }
end
class Foo < Base
  prop :ups, :upcase
  prop :strs, :to_s
end
p Foo.new.ups(%w[a b]), Foo.new.strs([1, 2])
