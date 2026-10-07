# trap / Signal.trap / ::Signal.trap at every shape: the block runs when the
# signal arrives (test/trap_raise_pending.rb, test/signal_default_interrupt.rb),
# and a program that never sends the signal sees only the return value, which
# in expression position is "DEFAULT" -- CRuby's value for any signal that
# was never previously trapped.
#
# Each section uses a distinct signal name so no signal's state is
# observed twice (CRuby would return the prior handler on the second
# touch, which Spinel does not yet model).

# Stmt position, implicit-self.
trap("INT") { puts "handler" }

# Stmt position, explicit Signal receiver (ConstantReadNode).
Signal.trap("TERM") { puts "handler" }

# Stmt position, toplevel ::Signal receiver (ConstantPathNode).
::Signal.trap("HUP") { puts "handler" }

# Stmt position, no block.
trap("QUIT", "EXIT")

# Expr position, first call on a never-trapped signal returns "DEFAULT".
prev = trap("USR1") { puts "x" }
puts prev

# Expr position via Signal receiver, also returns "DEFAULT" on first call.
prev2 = Signal.trap("USR2") { puts "y" }
puts prev2

puts "done"
