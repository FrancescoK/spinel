# A trap proc raises while a second delivery of its own signal is pending.
# The raise is rescued, and the pending delivery still runs the proc once
# more afterwards (CRuby's exact interleaving differs, so only count runs).
$runs = 0
Signal.trap("USR1") do
  $runs += 1
  if $runs == 1
    Process.kill("USR1", Process.pid)
    raise "first"
  end
end

begin
  Process.kill("USR1", Process.pid)
  sleep 0.1
rescue => e
  puts "rescued #{e.message}"
end
i = 0
while $runs < 2 && i < 50
  sleep 0.01
  i += 1
end
puts "runs: #{$runs}"
