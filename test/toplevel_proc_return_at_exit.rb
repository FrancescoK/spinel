ObjectSpace.define_finalizer("abc".dup, proc { puts "finalized" })
at_exit { puts "at_exit" }
pr = proc { return }
puts "before"
pr.call
puts "unreachable"
