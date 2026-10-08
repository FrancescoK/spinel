# spinel: gc-stress
# The class of a rescued error, raised again. `raise e.class, "m"` stores the
# class's name in the new error, and that name was the fresh copy `e.class`
# made on the string heap: nothing marks an error's class name, so the copy
# was collected while the message was built, and the new error's class, its
# is_a? and the `rescue` arms that test it answered with whatever String took
# the copy's place.
class Slow < StandardError; end
class Other < StandardError; end

# handed to a Thread; first, while the main thread has rescued nothing else
t = Thread.new do
  begin
    sleep 2
  rescue StandardError => e
    [e.class, e.message, e.is_a?(Slow)]
  end
end
sleep 0.05
begin
  raise Slow, "orig"
rescue => e
  t.raise(e.class, "m")
end
p t.value

def again(e, n)
  raise e.class, "m" + n.to_s
end

def by_method(n)
  begin
    raise Slow, "orig"
  rescue => e
    again(e, n)
  end
rescue Slow => x
  [x.class, x.message, x.is_a?(Slow)]
end
p by_method(1)

# a longer message
def longer(n)
  begin
    raise Other, "orig"
  rescue => e
    raise e.class, "m" * n
  end
rescue Other => x
  [x.class, x.message.size, x.is_a?(Other), x.is_a?(Slow)]
end
p longer(40)

# the class read off an error kept in a mixed Array
kept = [0]
begin
  raise Slow, "one"
rescue => e
  kept << e
end
begin
  raise kept[1].class, "re" + kept.size.to_s
rescue Other
  puts "an Other"
rescue Slow => z
  p [z.class, z.message]
end

# and to a Fiber
f = Fiber.new do
  begin
    Fiber.yield 1
  rescue StandardError => e
    [e.class, e.message, e.is_a?(Other)]
  end
end
f.resume
begin
  raise Other, "orig"
rescue => e
  p f.raise(e.class, "m")
end
