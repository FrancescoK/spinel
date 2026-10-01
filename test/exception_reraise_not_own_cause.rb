# An exception raised again from its own rescue is not its own cause: a
# bare `raise`, a `raise e` of the handled exception, and a bare `raise`
# that passes through an ensure leave the cause it had (here none).
begin
  begin
    raise "bare"
  rescue
    raise
  end
rescue => e
  p e.cause.nil?
end

begin
  begin
    raise "named"
  rescue => f
    raise f
  end
rescue => e
  p [e.equal?(f), e.cause.nil?]
end

original = RuntimeError.new("through ensure")
begin
  begin
    raise original
  rescue
    begin
      raise
    ensure
      puts "ensure ran"
    end
  end
rescue => e
  p [e.equal?(original), original.cause.nil?]
end

# One that has a cause keeps it, also re-raised into a modifier rescue, as
# a statement and as a value; a different exception raised in the rescue
# still takes the handled one as its cause.
begin
  begin
    raise "first"
  rescue
    raise "second"
  end
rescue => e
  (raise) rescue nil
  v = ((raise e) rescue 1)
  p [e.message, e.cause.message, v]
end
