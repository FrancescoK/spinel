# String#unpack with a block yields each value it decodes and answers nil,
# as CRuby's does. The block was ignored and the call answered the Array.
# A `&` operand that is nil gives no block, and the call answers the Array:
# a nil local, a method answering nil, a block parameter given none, an
# anonymous `&`. The receiver, the arguments and then the `&` operand run
# in that order. A class of the program defining its own unpack does not
# stop a String's.

p "Hello".unpack("C*") { |x| p x }
seen = []
r = "AB".unpack("C*") { |v| seen << v }
p r, seen
p "Hi".unpack("C*", offset: 1) { |x| p x }
p "\x01\x00\x02\x00".unpack("v*") { |v| p v * 10 }
p "ab".unpack("a1 a1") { |s| p s.upcase }
show = proc { |v| p v }
p "AB".unpack("C*", &show)

def decode(s)
  total = 0
  s.unpack("C*") { |b| total += b }
  total
end
p decode("AB")

def first_word(str) = str.unpack("a2") { |w| p w }
p first_word("xyz")
p "AB".unpack("C*")

class Packet
  def unpack(fmt) = yield(fmt.size)
end
p "ab".unpack("C*") { |x| p x }, Packet.new.unpack("xy") { |n| n * 2 }

def none = nil
nb = nil
p "AB".unpack("C*", &nil), "AB".unpack("C*", &nb), "AB".unpack("C*", &none)
maybe = ARGV.empty? ? proc { |v| p [:maybe, v] } : nil
p "AB".unpack("C*", &maybe), "AB".unpack("C*", &:itself)
def fwd(s, &b) = s.unpack("C*", &b)
p fwd("AB") { |v| p [:fwd, v] }, fwd("AB")
def anon(s, &) = s.unpack("C*", &)
p anon("AB") { |v| p [:anon, v] }, anon("AB")
calls = 0
mk = -> { calls += 1; calls.odd? ? proc { |v| p [:mk, v] } : nil }
p "AB".unpack("C*", &mk.call), "AB".unpack("C*", &mk.call), calls
log = []
lp = proc { |v| log << v }
p((log << :r; "AB").unpack((log << :a; "C*"), &(log << :b; lp)), log)
log.clear
p((log << :r; "AB").unpack((log << :a; "C*"), &(log << :b; nil)), log)
log.clear
p((log << :r; "ABC").unpack((log << :a; "C*"), offset: (log << :o; 1), &(log << :b; lp)), log)
LOG = []
def rcv = (LOG << :r; "AB")
def fmt = (LOG << :a; "C*")
def blk = (LOG << :b; proc { |v| LOG << v })
def nob = (LOG << :b; nil)
rcv.unpack(fmt, &blk)
p LOG
LOG.clear
p rcv.unpack(fmt, &nob), LOG
