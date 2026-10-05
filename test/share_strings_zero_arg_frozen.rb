# concat and prepend with no arguments still check that their receiver is
# not frozen, also for a String the rule shares.
f1 = "hello"; r1 = (f1.concat rescue $!.class)
f2 = "hello"; r2 = (f2.prepend rescue $!.class)
m = +"hi"; m2 = m; m2 << "!"
p r1, r2, m.concat, m.prepend, m2
f1.concat("x") rescue p $!.class
