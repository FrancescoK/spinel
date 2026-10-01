# warn(..., uplevel: 0) writes its prefix where the message goes -- here
# $stdout, through `$stderr = $stdout` -- and only once the message has been
# evaluated: a message that raises prints nothing at all.
$stderr = $stdout
warn("to stdout", uplevel: 0)
def msg(x) = x > 0 ? "m#{x}" : raise("boom")
begin
  warn(msg(0), uplevel: 0)
rescue => e
  puts "rescued #{e.message}"
end
warn(msg(2), "second", uplevel: 0)
