# A block kept and run later keeps every loop's StopIteration handler
# A Proc, a Hash's default proc or a block a method captures runs where it
# is called, inside a loop whose body does not name it: one that may raise
# StopIteration leaves no loop known not to, and each still ends at the
# StopIteration.

# a Proc called in the body
stop = proc { raise StopIteration }
n = 0
loop do
  n += 1
  stop.call if n == 2
end
p n

# a Hash's default proc runs where the Hash is read
g = [7, 8].each
h = Hash.new { |_, key| g.next }
vals = []
loop { vals << h[vals.size] }
p vals

# a method keeps the block it captures as `&blk`, and runs it later
class Later
  def store(&blk) = @blk = blk
  def run = @blk.call
end
src = [9].each
later = Later.new
later.store { src.next }
ran = 0
loop do
  ran += 1
  later.run
end
p ran

i = 0
loop do
  i += 1
  break if i == 3
end
p i
