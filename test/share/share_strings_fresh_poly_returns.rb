# A boxed call is fresh only when both its builtin and user arms are.
# inspect returns its own String through either arm, including a wrapper.
class FreshInspection
  def inspect = +"user"
end

def describe(value)
  value.inspect
end

source = +"source"
[source, FreshInspection.new, 7, :symbol, nil, [1], { a: 2 }].each do |value|
  text = value.inspect
  other = text
  other << "!"
  p [text, text.equal?(other)]
  wrapped = describe(value)
  alias_text = wrapped
  alias_text << "?"
  p [wrapped, wrapped.equal?(alias_text)]
end
p source
p [source, FreshInspection.new].map { |value| value.inspect }
