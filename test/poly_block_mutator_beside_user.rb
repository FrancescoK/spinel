# An in-place block mutator (map!, delete_if, select!, ...) on a boxed
# Array or Hash while a class of the program's own (here Set) defines the
# same method: the Array or Hash still runs its own. It raised
# NoMethodError, where only the class's arm was in the dispatch.
require "set"

def pick(a, i) = a[i]
v = pick([[1, 2], Set[3, 4]], 0)
p v.map!(&:succ), v
p pick([[1, 2, 3], Set[3, 4]], 0).collect! { |x| x * 10 }
p pick([[1, nil, 2, nil], Set[5]], 0).delete_if { |e| e.nil? }
p pick([[1, 2, 3, 4], Set[5]], 0).select! { |x| x.even? }
p pick([[1, 2, 3, 4], Set[5]], 0).reject! { |x| x > 2 }
p pick([[2, 4], Set[5]], 0).select! { |x| x.even? }
p pick([[1, 2, 3], Set[5]], 0).keep_if { |x| x != 2 }
p pick([[1, 2, 3], Set[5]], 0).filter! { |x| x > 1 }
p pick([{ a: 1, b: nil }, Set[5]], 0).delete_if { |k, x| x.nil? }
p pick([{ a: 1, b: 2 }, Set[5]], 0).select! { |k, x| x > 1 }

# the class still takes its own
w = pick([[1, 2], Set[3, 4]], 1)
p w.map! { |x| x * 2 }
p pick([[1], Set[3, 4, 5]], 1).delete_if { |x| x == 4 }
p pick([[1], Set[3, 4, 5]], 1).select! { |x| x > 3 }
