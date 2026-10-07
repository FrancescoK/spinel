# SIGINT and SIGTERM with no trap raise Interrupt / SignalException in the main
# thread, as CRuby's default does, so rescue and ensure run (#7202). An Interrupt
# nothing rescues ends the process by SIGINT, which `make signal-default-test` checks.
$stdout.sync = true
begin
  Process.kill("INT", Process.pid)
  sleep 1
  puts "not interrupted"
rescue Interrupt => e
  puts "rescued #{e.class} (#{Signal.signame(e.signo)}) #{e.message.inspect}"
end
begin
  Process.kill("TERM", Process.pid)
  sleep 1
rescue SignalException => e
  p [e.class, e.message, e.signo]
end
begin
  begin
    Process.kill("INT", Process.pid)
    sleep 1
  ensure
    puts "ensure ran"
  end
rescue Interrupt
  puts "after ensure"
end
i = 0
begin
  Process.kill("INT", Process.pid)
  loop { i += 1 }
rescue Interrupt
  puts "left a tight loop"
end
