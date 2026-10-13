# Array#bsearch and #bsearch_index take a forwarded block (&blk) and a
# boxed receiver (an Array known only at run time), in find-minimum and
# find-any mode.
def fwd(&blk) = [1, 2, 3].bsearch(&blk)
def fwd_i(&blk) = [10, 20, 30].bsearch_index(&blk)
p fwd { |x| x >= 2 }, fwd { |x| x > 5 }
p fwd_i { |x| x >= 15 }, fwd_i { |x| 20 <=> x }

def pos_of(a, pos) = a.bsearch_index { |x| pos < x } || a.size - 1
def first_over(a, pos) = a.bsearch { |x| pos < x }
p pos_of([0, 3, 5], 2), pos_of([0, :x].take(1), 2)
p first_over([0, 3, 5], 2), first_over([0, :x].take(1), 2)

def boxed_fwd(a, &blk) = a.bsearch_index(&blk)
p boxed_fwd([1, 4, 9]) { |x| x >= 4 }, boxed_fwd([1, :a].take(1)) { |x| x >= 4 }
def boxed_fwd_e(a, &blk) = a.bsearch(&blk)
p boxed_fwd_e([1, 4, 9]) { |x| x >= 4 }, boxed_fwd_e([1, :a].take(1)) { |x| x >= 4 }
