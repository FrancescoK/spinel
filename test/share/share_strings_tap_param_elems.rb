# A block parameter that tap, then or yield_self hands a String Array,
# whose Strings the program mutates, holds the Array in the poly form the
# sharing rule settles it in, with the handles in its boxes. The pass that
# types the parameter from its receiver set it back to the typed String
# Array every round, the rule converted it again, and the inference ran to
# its round cap.

kept = []
"x y".split(" ").tap { |a| a[3] = nil }.each { |e| kept << e; e << "!" if e }
p kept

kept = []
"x y".split(" ").then { |a| a[3] = nil; a }.each { |e| kept << e; e << "!" if e }
p kept

kept = []
"x y".split(" ").yield_self { |a| a << nil; a }.each { |e| kept << e; e << "!" if e }
p kept

kept = []
"x y".split(" ").tap { _1[1] = nil }.each { |e| kept << e; e << "!" if e }
p kept

kept = []
"x y".split(" ").tap { it[2] = nil }.each { |e| kept << e; e << "!" if e }
p kept
