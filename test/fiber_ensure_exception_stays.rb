# The exception an ensure body runs for belongs to the fiber that body runs
# in. A raise in another fiber does not take it as its cause, and the body
# still has it when its fiber is resumed.

def later
  raise "later"
rescue => e
  e.cause.inspect
end

f = Fiber.new do
  begin
    raise "in the fiber"
  ensure
    Fiber.yield 1
  end
end
f.resume
puts "outside a suspended ensure: #{later}"

# back in the fiber, the ensure body's raise takes its own
g = Fiber.new do
  begin
    begin
      raise "first"
    ensure
      Fiber.yield 1
      raise "second"
    end
  rescue => e
    "#{e.message}, cause #{e.cause.inspect}"
  end
end
g.resume
keep = []
2000.times { |i| keep << "k" + i.to_s }
later
puts "resumed: #{g.resume}"

# the mirror: an ensure body of main resumes a fiber that raises
h = Fiber.new { later }
begin
  begin
    raise "outer"
  ensure
    puts "in a fiber under main's ensure: #{h.resume}"
  end
rescue => e
  puts "#{e.message}, cause #{e.cause.inspect}"
end

# and main's ensure body has its own after the fiber came back
begin
  begin
    raise "outer"
  ensure
    k = Fiber.new { later }
    k.resume
    raise "from the ensure"
  end
rescue => e
  puts "#{e.message}, cause #{e.cause.inspect}"
end

# two fibers, each suspended in an ensure body
a = Fiber.new do
  begin
    begin
      raise "a's"
    ensure
      Fiber.yield 1
      raise "a again"
    end
  rescue => e
    "#{e.message}, cause #{e.cause.inspect}"
  end
end
b = Fiber.new do
  begin
    begin
      raise "b's"
    ensure
      Fiber.yield 1
      raise "b again"
    end
  rescue => e
    "#{e.message}, cause #{e.cause.inspect}"
  end
end
a.resume
b.resume
puts a.resume
puts b.resume
puts "after both: #{later}"

# a fiber that is in no ensure body, resumed under one
n = 0
100.times do |i|
  w = Fiber.new do
    Fiber.yield later
    later
  end
  begin
    begin
      raise "outer #{i}"
    ensure
      n += 1 if w.resume == "nil"
    end
  rescue => e
    n += 1 if w.resume == "nil" && e.cause.nil?
  end
end
p n
