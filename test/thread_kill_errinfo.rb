# A thread killing itself, or a fiber being killed, runs its ensures with
# $! nil, as CRuby does: the kill is no exception to the program (#8378).
# A raise still shows in an ensure it passes through.
Thread.new do
  begin
    Thread.current.kill
  rescue
    p :not_here
  ensure
    p $!.nil?
  end
end.join
f = Fiber.new do
  begin
    Fiber.yield 1
  ensure
    p $!.nil?
  end
end
f.resume
f.kill
begin
  begin
    raise "seen"
  ensure
    p $!&.message
  end
rescue
end
