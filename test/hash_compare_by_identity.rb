# Hash#compare_by_identity where every key is an object compared by pointer,
# or a Symbol, nil, true or false (#9171): keys are found by equal?, as
# CRuby finds them. A program class's instance whose eql? and hash say two
# instances are one key is two keys after it; an Array or a Hash key is its
# object, not its content; a hash that already holds entries is rebuilt;
# compare_by_identity? answers true. io-event keys its waiters by IO this
# way, and json_schemer its locations by Hash.
class Key
  attr_reader :n
  def initialize(n) = @n = n
  def hash = @n.hash
  def eql?(o) = o.is_a?(Key) && o.n == @n
end

a = Key.new(1)
plain = {}
plain[a] = 1
plain[Key.new(1)] = 2
p plain.size, plain.compare_by_identity?

ident = {}.compare_by_identity
ident[a] = 1
ident[Key.new(1)] = 2
p ident.size, ident[a], ident.compare_by_identity?
ident.delete(a)
p ident.size, ident.key?(a)

later = {}
later[a] = 1
later[Key.new(1)] = 2
later.compare_by_identity
later[Key.new(1)] = 3
p later.size, later[a], later.compare_by_identity?

loc = Hash.new.compare_by_identity
k1 = [1, 2]
loc[k1] = :first
loc[[1, 2]] = :second
p loc.size, loc[k1], loc.key?([1, 2])
hk = {"x" => 1}
loc[hk] = :hash
p loc[hk], loc.key?({"x" => 1})

syms = {}.compare_by_identity
syms[:x] = 1
syms[:x] = 2
syms[nil] = 3
p syms.size, syms[:x], syms.compare_by_identity?

r, w = IO.pipe
ready = Hash.new(0).compare_by_identity
ready[r] |= 1
ready[w] |= 2
ready[r] |= 4
p ready.map { |_io, e| e }, ready.size
ready.delete_if { |io, _| io == w }
p ready.size

frozen = Hash.new.compare_by_identity
frozen[a] = 1
frozen.freeze
p frozen.frozen?, frozen[a]
