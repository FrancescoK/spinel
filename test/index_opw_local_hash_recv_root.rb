# spinel: gc-stress
# `h[key] op= v` on a Hash held in a local: a key that runs code (a call,
# one that allocates) or a fold on a poly value leaves the local alone, so
# the local's own root still holds the hash and the receiver's temp is not
# rooted again on every turn. A key or a right-hand side that rebinds the
# local, directly or through a closure over it, leaves the temp the old
# hash's only holder, and keeps its root.

def pick(words, i) = words[i % words.size]
def junk = Array.new(500) { |i| "j#{i}" }.size
# a receiver only its local holds: a literal's own temp would hold it too
def fresh = { "a" => 1 }

# Integer keys from a call
def bytes(rows)
  h = Hash.new(0)
  i = 0
  while i < rows.bytesize
    h[rows.getbyte(i)] += 1
    i += 1
  end
  h
end
p bytes("abcab" * 40)

# String keys the key expression allocates
def words(ws, n)
  h = Hash.new(0)
  i = 0
  while i < n
    h[pick(ws, i).upcase] += junk
    i += 1
  end
  h
end
p words(%w[a b c], 30)

# poly values: the fold is a call that allocates
def mixed(n)
  h = { "a" => "x", "b" => 1 }
  i = 0
  while i < n
    h[pick(%w[a b], i).dup] += (i.even? ? "y" * 50 : 2)
    i += 1
  end
  [h["a"].size, h["b"]]
end
p mixed(20)

# the key rebinds the receiver's local: the write lands in the old hash,
# which nothing else holds while the key allocates
def rebind_key
  h = fresh
  h[(h = { "z" => junk }; junk; "a")] += 5
  h
end
p rebind_key

# ...and the right-hand side
def rebind_rhs
  h = fresh
  h[pick(%w[a], 0)] += (h = { "z" => junk }; junk - 498)
  h
end
p rebind_rhs

# a closure over the local rebinds it from inside the key
def rebind_proc
  h = fresh
  swap = -> { h = { "z" => junk }; junk; "a" }
  h[swap.call] += 7
  h
end
p rebind_proc

class Counter
  def initialize
    @h = { "a" => 1 }
  end

  def swap
    @h = { "z" => junk }
    junk
    "a"
  end

  def run
    @h[swap] += 1
    @h
  end
end
p Counter.new.run
