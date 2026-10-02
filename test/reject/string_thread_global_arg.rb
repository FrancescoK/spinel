# A global handed to a thread's block, which appends to it, and read again:
# the block's parameter takes a box of a copy of the global's String, so the
# append would not reach it. Refused rather than compiled with the append
# lost.
$g = +"g"
Thread.new($g) { |t| t << "y" }.join
p $g
