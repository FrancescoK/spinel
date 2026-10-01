# A builtin exception class's reopening that defines initialize is run by
# `raise Cls, msg`, `raise Cls` and `Cls.new(msg)`, its `super(msg)` setting
# the message; an exception the runtime raises itself keeps its own.
class KeyError
  def initialize(msg = "no key", receiver: nil, key: nil)
    super("wrapped: #{msg}")
  end
end
begin
  raise KeyError, "x"
rescue KeyError => e
  p e.message
end
begin
  raise KeyError
rescue KeyError => e
  p e.message
end
p KeyError.new("y").message
begin
  {a: 1}.fetch(:zz)
rescue KeyError => e
  p e.message
end
