# A local read is an operand of a builtin's call like any other: when an
# operand before it can rebind the local, the read takes the value that
# operand left, as Ruby evaluates left to right. `s.byteslice(bump.call, pos)`
# for a lambda that advances pos left the call the only ordered operand, and
# C read pos beside it -- the old value under gcc on x86_64, which evaluates
# the arguments right to left. A read rebound by a later operand
# (`v.divmod(la.call)`) was already ordered.

pos = 0
bump = lambda do
  pos += 2
  1
end

station = "Jayang Station"
p station.byteslice(bump.call, pos)
pos = 0
p station[bump.call, pos]
pos = 0
p [10, 20, 30, 40, 50].slice(bump.call, pos)
pos = 0
p "Guui".center(bump.call + 5, pos.to_s)
pos = 0
packet = [7, 2, 0x4b, 0x6f].pack("C*")
p packet.unpack("C", offset: bump.call + pos)
pos = 0
p packet.unpack1("C", offset: [bump.call, pos].max)

# an assignment written as an earlier operand
p station.byteslice((pos = 7; 0), pos)

# a method whose block rebinds the local
def run_twice
  yield
  yield
  3
end
n = 0
p "Kondae lamb skewers".byteslice(run_twice { n += 1 }, n)

# a read no earlier operand rebinds stays a plain read
k = 2
p station.byteslice(k + 1, k)
