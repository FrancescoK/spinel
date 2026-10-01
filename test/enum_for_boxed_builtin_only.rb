# enum_for on a boxed value in a program where no class of its own
# iterates: the builtin's Enumerator.
vals = [[1, 2], { a: 1 }, (4..5)]
vals.each { |v| p v.enum_for.to_a }
p vals[0].to_enum.map { |x| x * 10 }
