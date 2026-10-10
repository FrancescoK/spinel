# `cause: nil` decides the cause: an ensure the exception passes through,
# inside a rescue of another one, re-raises it with no cause, where the
# re-raise took the handled exception as its cause (#8375). A cause a raise
# took stays the first one when the exception is raised again.
begin
  raise "ambient"
rescue
  begin
    begin
      raise "first"
    rescue
      raise "last", cause: nil
    ensure
      nil
    end
  rescue => e
    p e.cause&.message
  end
  begin
    begin
      raise "first"
    rescue
      raise "kept"
    ensure
      nil
    end
  rescue => e
    p e.cause&.message
  end
end
class Again < StandardError; end
x = nil
begin
  begin
    raise "one"
  rescue
    raise Again, "two"
  end
rescue Again => e
  x = e
end
begin
  raise "three"
rescue
  begin
    raise x
  rescue Again => e2
    p e2.cause&.message
  end
end
