# A block call as a statement on a boxed Array or Hash while a class of the
# program's own (here Set) defines the same method: the Array or Hash runs
# its own. The builtin's arm ends in a NoMethodError for a receiver of no
# kind that has the method, and that tail was read as the builtin declining
# the call, so an Array raised NoMethodError.
require "set"

def pick(a, i) = a[i]

def without_nils(i)
  kids = pick([[1, nil, 2], Set[3, nil], { a: nil, b: 1 }], i).dup
  kids.delete_if { |e| e.nil? } if i < 2
  kids.delete_if { |_, v| v.nil? } if i == 2
  return :empty if kids.empty?
  kids
end
p without_nils(0), without_nils(1), without_nils(2)

def kept(i)
  xs = pick([[1, 2, 3, 4], Set[1, 2, 3]], i).dup
  xs.keep_if { |x| x.odd? }
  xs
end
p kept(0), kept(1)

def selected(i)
  xs = pick([[1, 2, 3, 4], Set[1, 2, 3]], i).dup
  xs.select! { |x| x > 1 }
  xs.reject! { |x| x == 3 }
  xs
end
p selected(0), selected(1)

def nothing(i)
  xs = pick([[], Set[]], i)
  xs.delete_if { |x| x }
  xs.empty?
end
p nothing(0), nothing(1)
