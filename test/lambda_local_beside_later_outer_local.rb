# A local first assigned inside a lambda is the lambda's own when the
# enclosing scope assigns that name only after the lambda's text (here a
# `rescue => e` below it): two variables, each with its own type.
class Gone < StandardError; end

BEHAVIORS = {
  raise: ->(message, callstack) do
    e = Gone.new(message)
    e.set_backtrace(callstack.map(&:to_s))
    raise e
  end,
  count: ->(message, _) { e = message.size; e * 2 },
}
square = ->(x) { e = x * x; e }

begin
  BEHAVIORS[:raise].call("gone", [:here])
rescue Gone => e
  p [e.class, e.message, e.backtrace]
end
p BEHAVIORS[:count].call("abc", nil), square.(7)
e = "outer"
p e
