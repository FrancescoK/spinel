# A method that keeps its block's value from blk.call, where the block ends
# with an append to a String the caller holds, takes that String itself:
# the value is the shared handle, boxed as the call answers it (#8399).
def keep(&blk)
  last = blk.call
  last
end

buf = +"k"
keep { buf << "a" }
p buf
x = keep { buf << "b" }
x << "!"
p buf, x.equal?(buf)
