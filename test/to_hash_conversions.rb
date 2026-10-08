class TH
  def to_hash = {chomp: true}
end

class Bad
  def to_hash = 5
end

class Opts
  def hash_value = {b: 2}
  alias to_hash hash_value
end

class Named
  def named = {n: 1}
  alias_method :to_hash, :named
end

class Plain
  def to_hash = {c: 3}
end

def hh(x) = Hash(x)
p hh(nil)
p hh([])
p hh({a: 1})
p hh(TH.new)
p hh(Opts.new)
[1, "s", :x, [[1, 2]], 1.5, true, Object.new, Bad.new].each do |v|
  hh(v)
rescue TypeError => e
  p e.message
end

p Hash(nil)
p Hash([])
p Hash({a: 1})
p Hash(TH.new)
p Hash(Opts.new)
begin
  Hash(1)
rescue TypeError => e
  p e.message
end

def take(h)
  "a\nb\n".lines(chomp: (kv = Hash(h); kv.fetch(:chomp, false)))
end
p take(TH.new)
p take(nil)
p take({chomp: true})

p({a: 1}.merge(Opts.new))
p({a: 1}.merge(Named.new))
p({a: 1}.merge(Plain.new))

def mg(r, x) = r.merge(x)
p mg({a: 1}, Opts.new)
p mg({a: 1}, Plain.new)
p mg({a: 1}, {d: 4})
