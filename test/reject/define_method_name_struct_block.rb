# spinel: reject-subclass: Module#define_method with a non-literal name
NAMES = [:limit, :null, :primary_key].freeze
ColumnDefinition = Struct.new(:options) do
  (NAMES - [:primary_key]).each do |option_name|
    define_method(option_name) { options[option_name] }
  end
end
p ColumnDefinition.new({limit: 1}).limit
