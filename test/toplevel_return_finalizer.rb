ObjectSpace.define_finalizer("abc".dup, proc { puts "finalized" })
at_exit { puts "at_exit" }
begin
  puts "main"
  return
ensure
  puts "ensure"
end
puts "unreachable"
