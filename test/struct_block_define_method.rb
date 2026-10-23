# define_method in a Struct.new / Data.define block defines the method on
# the struct class, as a def there does
ColumnDefinition = Struct.new(:name, :type, :options) do
  define_method(:limit) { options[:limit] }
  define_method(:limit=) { |value| options[:limit] = value }
  [:precision, :null].each do |option_name|
    define_method(option_name) { options[option_name] }
  end
  [].each { |option_name| define_method(:never) { option_name } }
end
c = ColumnDefinition.new(:title, :string, {null: false})
c.limit = 5
p c.limit
p c.precision
p c.null
p c.respond_to?(:never)

Point = Data.define(:x, :y) do
  define_method(:sum) { x + y }
end
p Point.new(x: 1, y: 2).sum

klass = Struct.new(:a) do
  define_method(:twice) { a * 2 }
end
p klass.new(21).twice
