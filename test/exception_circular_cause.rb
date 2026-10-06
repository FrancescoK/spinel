# An explicit cause: whose chain leads back to the raised exception is
# ArgumentError (circular causes); the exception itself as its cause is no change.
a = RuntimeError.new("a")
b = RuntimeError.new("b")
begin
  raise b, cause: a
rescue => e
end
begin
  raise a, cause: a
rescue => e
  p [e.message, e.cause&.message]
end
c = RuntimeError.new("c")
begin
  raise c, cause: RuntimeError.new("first")
rescue
end
begin
  raise c, cause: c
rescue => e
  p [e.message, e.cause&.message]
end
begin
  raise a, cause: b
rescue ArgumentError => e
  p [e.class, e.message, e.cause&.message, a.cause&.message]
end
