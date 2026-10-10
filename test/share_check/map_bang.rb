# map! over a String Array stores the block's answer over the element its
# parameter was bound to: the bytes that answer reads and rebuilds of the
# parameter are written back into the slot, and the check reports nothing.
p " a ,b,, c ".split(",", -1).map! { |x| x.strip! || x }
