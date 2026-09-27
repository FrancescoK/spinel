# A trap handler that raises leaves the signal handler by a jump, not a
# return, so the kernel never unblocks the signal it blocked for delivery.
# The next delivery then stays pending and the trap never fires again.
Signal.trap("USR1") { raise "trapped" }

3.times do |i|
  begin
    Process.kill("USR1", Process.pid)
    sleep 0.1
    puts "#{i}: not delivered"
  rescue => e
    puts "#{i}: rescued #{e.message}"
  end
end
puts "done"
