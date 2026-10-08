# An exception raised again while one of its own effects is being handled
# keeps the cause it had: taking that effect as its cause would close a ring,
# and a walk along the causes would never end.

def show(tag, x)
  n = 0
  c = x
  while c && n < 10
    n += 1
    c = c.cause
  end
  k = x.cause
  puts tag + ": " + x.message + " cause=" + (k ? k.message : "nil") + " chain=" + n.to_s
end

def cleanup
  raise IOError, "cleanup failed"
end

# the usual shape: the first error is raised again when the cleanup fails too
def work
  raise ArgumentError, "work failed"
rescue ArgumentError => orig
  begin
    cleanup
  rescue IOError
    raise orig
  end
end

begin
  work
rescue => x
  show("cleanup", x)
end

begin
  begin
    raise "a1"
  rescue => a
    begin
      raise "b1"
    rescue => b
      begin
        raise "c1"
      rescue
        raise a
      end
    end
  end
rescue => x
  show("three", x)
end

# the effect is in flight through an ensure, not handled
first = nil
begin
  raise "a2"
rescue => first
end
second = RuntimeError.new("b2")
begin
  begin
    raise second, cause: first
  ensure
    raise first
  end
rescue => x
  show("ensure", x)
end

# the same object raised from its own ensure
again = RuntimeError.new("a3")
begin
  begin
    raise again
  ensure
    raise again
  end
rescue => x
  show("itself", x)
end

# one that has a cause keeps it
root = KeyError.new("root")
kept = nil
begin
  raise "a4", cause: root
rescue => kept
end
begin
  begin
    raise "b4", cause: kept
  rescue
    raise kept
  end
rescue => x
  show("kept", x)
end

# no ring in sight: these take the handled exception as before
begin
  begin
    raise "h5"
  rescue
    raise "fresh"
  end
rescue => x
  show("fresh", x)
end

old = RuntimeError.new("old")
begin
  raise old
rescue
end
begin
  begin
    raise "h6"
  rescue
    raise old
  end
rescue => x
  show("unrelated", x)
end

total = 0
200.times do |i|
  begin
    begin
      raise "first " + i.to_s
    rescue => a
      begin
        raise "second " + i.to_s
      rescue
        raise a
      end
    end
  rescue => x
    total += x.message.size
    total += 1000 if x.cause
  end
end
puts total
