# A String raise carries only its message; an ensure it passes through,
# whose body collects, keeps that message for the raise after it (#8323).
# spinel: gc-stress
M = Mutex.new
begin
  begin
    M.synchronize { raise String.new("bad") }
  ensure
    GC.start
  end
rescue => e
  p e.message
end

begin
  begin
    raise String.new("plain") + "!"
  ensure
    GC.start
  end
rescue => e
  p e.message
end

begin
  begin
    raise ArgumentError, String.new("arg")
  ensure
    GC.start
  end
rescue ArgumentError => e
  p [e.class, e.message]
end

begin
  begin
    raise
  ensure
    GC.start
  end
rescue => e
  p [e.class, e.message]
end
