# A bare raise in an ensure re-raises the exception in flight, not a new one.
begin
  begin
    raise ArgumentError, "b"
  ensure
    raise
  end
rescue => e
  p [e.class.to_s, e.message]
end

# Without one in flight it is still an empty RuntimeError.
begin
  raise
rescue => e
  p [e.class.to_s, e.message]
end
