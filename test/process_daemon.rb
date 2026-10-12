# Process.daemon(nochdir, noclose) takes true, false or nil and checks noclose
# first. What the program printed before it is written once, by the parent,
# which then leaves with status 0: the code after the call and the at_exit
# handlers run only in the daemon, whose stdout is /dev/null.
def try_daemon(*args)
  case args.size
  when 0 then Process.daemon
  when 1 then Process.daemon(args[0])
  when 2 then Process.daemon(args[0], args[1])
  else Process.daemon(args[0], args[1], args[2])
  end
rescue ArgumentError => e
  puts e.message
end

try_daemon(1)
try_daemon(true, 1)
try_daemon(1, "x")
try_daemon(:yes, nil)
try_daemon(nil, nil, nil)
begin
  Process.daemon(p(1), p(2), p(3))
rescue ArgumentError => e
  puts e.message
end

at_exit { puts "at_exit ran" }
print "before"
Process.daemon
puts "after"
