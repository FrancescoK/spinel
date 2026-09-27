# A trap proc throws while a second delivery of its own signal is pending.
# That delivery runs a proc which raises and rescues internally; the throw
# still has to reach its catch rather than be dropped along the way.
def helper
  begin
    raise "inner"
  rescue => e
    "caught #{e.message}"
  ensure
    puts "helper ensure"
  end
end

$runs = 0
Signal.trap("USR1") do
  $runs += 1
  if $runs == 1
    Process.kill("USR1", Process.pid)
    throw :t
  else
    puts helper
  end
end

r = catch(:t) do
  Process.kill("USR1", Process.pid)
  sleep 0.1
  :not_thrown
end
i = 0
while $runs < 2 && i < 50
  sleep 0.01
  i += 1
end
puts "r: #{r.inspect}"
puts "runs: #{$runs}"
