# A by-reference String parameter stores through a slot the callee cannot name
# the owner of, so the write barrier has no owner to mark and the minor mark
# never reaches the young string the store put there (#4391).
#
# Every arm here is one of the shapes a lending call site can take, because
# which of them needs recording is the whole question: a stack local is rooted
# by the caller's frame and needs nothing, a heap cell and an ivar's owner need
# to be remembered, and FORWARDING a lent parameter needs nothing because
# whatever the original site was, it already decided.
#
# The answer is a length, not a checksum, because that is how the fault shows:
# the buffer comes back short, silently. Before the fix the first arm answered
# 630 under SPINEL_GC_MINOR=1 and 39375 without it. The leg runs both modes
# against this file, so an arm that only works with the minor mark off fails.
# spinel: gc-stress
# spinel: gc-minor
FRAG = "-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

def fill(io, n)
  i = 0
  while i < n
    io << "f#{i}#{FRAG}"
    i += 1
  end
  nil
end

# forwarding: this callee lends the parameter it was lent
def fill_via(io, n)
  fill(io, n)
  nil
end

# --- 1. the cell lives in a long-lived proc's capture struct ---

PROCS = []
def make_proc
  buf = String.new
  PROCS << proc { fill(buf, 3); buf.size }
end

# --- 2. a captured local lent directly, from the scope that owns the cell ---

def capture_owner(rounds)
  buf = String.new
  keep = proc { buf.size }          # captures buf, so buf becomes a heap cell
  i = 0
  while i < rounds
    fill(buf, 2)
    i += 1
  end
  keep.call
end

# --- 3. an ivar lent to a callee that appends into the object ---

class Sink
  def initialize
    @buf = String.new
  end

  def take(n)
    fill(@buf, n)
    nil
  end

  def size
    @buf.size
  end
end

# --- 4. control: a plain stack local, which the caller's frame roots ---

def stack_owner(rounds)
  buf = String.new
  i = 0
  while i < rounds
    fill_via(buf, 2)
    i += 1
  end
  buf.size
end

8.times { make_proc }
sink = Sink.new

junk = []
r = 0
last = 0
while r < 3000
  junk << "j#{r}#{FRAG}"
  junk.shift while junk.size > 20
  last = PROCS[r % 8].call
  sink.take(1)
  r += 1
end

puts "capture slot #{last}"
puts "cell owner #{capture_owner(400)}"
puts "ivar #{sink.size}"
puts "stack #{stack_owner(400)}"
