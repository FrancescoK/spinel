# Kernel#warn writes to $stderr, so reassigning it to another IO sends the
# warnings there too, in order with that IO's own output.
$stderr = $stdout
warn "x"
$stderr.puts "y"
warn "a", "b"
warn ["l1", "l2"]
warn 42
Warning[:deprecated] = true
warn "dep", category: :deprecated
puts "done"
