# Timeout::Error is a RuntimeError and Timeout::ExitException an Exception,
# so a program can raise and rescue them by name without calling
# Timeout.timeout.
require "timeout"

p Timeout::Error.superclass
p Timeout::ExitException.superclass
begin
  raise Timeout::Error, "execution timeout"
rescue Timeout::Error => e
  puts "rescued #{e.class}: #{e.message}"
end
begin
  raise Timeout::Error
rescue RuntimeError => e
  puts "as RuntimeError: #{e.class}"
end
