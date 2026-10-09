# spinel: share
# A nil exception receiver follows nil's method lookup before text dispatch.
class NullableTextError < StandardError
  def to_s = "text"
end
def nullable_message(n)
  receiver = n == 0 ? nil : NullableTextError.new
  receiver.message
rescue NoMethodError
  "missing"
end
p nullable_message(0), nullable_message(1)
def nullable_to_s(n)
  receiver = n == 0 ? nil : NullableTextError.new
  receiver.to_s
end
p nullable_to_s(0), nullable_to_s(1)
p nullable_to_s(0).frozen?, nullable_to_s(0).equal?(nil.to_s)
