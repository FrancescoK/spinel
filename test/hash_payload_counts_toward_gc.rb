# A Hash keeps its tables -- keys, values, insertion order -- outside its own
# slot, and the collector's trigger never saw them: building a large Hash
# moved the live-byte counter by the Hash's header alone. A program that built
# large Hashes and dropped them ran no collection at all, and every dropped
# table stayed allocated, so its memory grew with the number of rounds.
#
# Each kind of Hash is churned with keys and values made beforehand, so the
# tables are the only thing that grows, and a collection must have run while
# it did. The Poly-keyed one is rehashed as it goes, which hands a fresh
# table's count over to the Hash; the subclass embeds its Hash, whose tables
# count toward the instance.
ROUNDS = 40
N = 20_000

class Key
  def initialize(i)
    @i = i
  end
end

class Table < Hash
end

# GC.stat's "cycle" is spinel's count of collections; CRuby's is :count
def collections
  s = GC.stat
  s.key?("cycle") ? s["cycle"] : GC.stat(:count)
end

def report(name, before)
  puts name + ": collected while churning: " + (collections > before ? "yes" : "no")
end

str_keys = Array.new(N) { |i| "k" + i.to_s }
obj_keys = Array.new(N) { |i| Key.new(i) }
mixed = [1, "one", :one, 1.0]

before = collections
total = 0
ROUNDS.times do |r|
  h = {}
  N.times { |i| h[i * 31 + r] = i }
  total += h.size
end
report("Integer => Integer", before)

before = collections
ROUNDS.times do |r|
  h = {}
  N.times { |i| h[i * 31 + r] = str_keys[i] }
  total += h.size
end
report("Integer => String", before)

before = collections
ROUNDS.times do |r|
  h = {}
  N.times { |i| h[str_keys[i]] = i + r }
  total += h.size
end
report("String => Integer", before)

before = collections
ROUNDS.times do |r|
  h = {}
  N.times { |i| h[str_keys[i]] = str_keys[(i + r) % N] }
  total += h.size
end
report("String => String", before)

before = collections
ROUNDS.times do |r|
  h = {}
  N.times { |i| h[str_keys[i]] = mixed[(i + r) % 4] }
  total += h.size
end
report("String => mixed", before)

before = collections
ROUNDS.times do |r|
  h = {}
  N.times { |i| h[obj_keys[i]] = i + r }
  h.rehash
  total += h.size
end
report("Object => Integer", before)

before = collections
ROUNDS.times do |r|
  t = Table.new
  N.times { |i| t[i * 31 + r] = i }
  total += t.size
end
report("Hash subclass", before)

puts total
