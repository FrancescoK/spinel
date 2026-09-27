# A signal that arrives while its own trap proc is running waits for the
# proc to finish; it doesn't run the proc again on top of itself. Here the
# proc re-sends its signal, so any nesting shows up as a depth above 1.
$depth = 0
$max_depth = 0
$runs = 0
Signal.trap("USR1") do
  $depth += 1
  $max_depth = $depth if $depth > $max_depth
  $runs += 1
  Process.kill("USR1", Process.pid) if $runs < 5
  $depth -= 1
end

Process.kill("USR1", Process.pid)
i = 0
while $runs < 5 && i < 50
  sleep 0.01
  i += 1
end
puts "runs: #{$runs}"
puts "max depth: #{$max_depth}"
