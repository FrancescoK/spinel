# A SIGINT that arrives while a loop that computes only on scalars runs
# inside a rescue or an ensure of its own method, which then reads two
# locals the loop steps together. CRuby takes an interrupt between passes
# only, so the two are always in step. A pure loop raised the signal where
# it landed, between the two statements of a pass, in about a third of the
# runs; inside an ensure, or a rescue that can catch an Interrupt, such a
# loop is chunked or polls at each pass instead. A `rescue => e` catches no
# Interrupt: its loop keeps the pure region, and the Interrupt passes on to
# the caller. A loop another loop encloses (a `1.times` block here) and a
# loop in a begin's else clause, which that begin's rescue does not cover,
# are in step too, and take the signal at all: such a nested counted loop
# polls at each run although another loop encloses it. Each loop's signal
# comes from a child started just ahead of it.
$stdout.sync = true
pid = Process.pid
def spin(pid)
  a = 0
  b = 0
  Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
  while true
    a += 1
    b += 1
  end
rescue Interrupt
  puts(a == b ? "def rescue in step" : "def rescue out of step")
end
def std_rescue(pid)
  a = 0
  Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
  while true
    a += 1
  end
rescue => e
  puts "rescue => e caught #{e.class}"
end
y = 0
i = 0
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  while i < 4_000_000_000_000
    y = y + 2
    i += 1
  end
rescue Interrupt
  puts(y == 2 * i ? "while in step" : "while out of step")
end
spin(pid)
s = 0
t = 0
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  begin
    4_000_000_000.times { |k| s += 3; t += 3 }
  ensure
    puts(s == t ? "ensure in step" : "ensure out of step")
  end
rescue Interrupt
end
begin
  std_rescue(pid)
rescue Interrupt
  puts "rescue => e passed it on"
end
u = 0
j = 0
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  1.times do
    while j < 4_000_000_000_000
      u = u + 2
      j += 1
    end
  end
rescue Interrupt
  puts(u == 2 * j ? "nested while in step" : "nested while out of step")
end
s = 0
t = 0
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  1.times do
    4_000_000_000.times { |k| s += 3; t += 3 }
  end
rescue Interrupt
  puts(s == t ? "nested times in step" : "nested times out of step")
end
y = 0
i = 0
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  begin
    y = 0
  rescue Interrupt
    puts "else rescued by its own begin"
  else
    while i < 4_000_000_000_000
      y = y + 2
      i += 1
    end
  end
rescue Interrupt
  puts(y == 2 * i ? "else in step" : "else out of step")
end
