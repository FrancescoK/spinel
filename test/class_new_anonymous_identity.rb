# spinel: share
# spinel: gc-minor
# A Class.new class keeps one identity for raise, rescue and comparison, prints
# as CRuby's #<Class:0x...> until a constant names it, and rejects a module
# as its superclass.
class IdentityBase
  def initialize = (@a = 1)
end
def mask(s) = s.sub(/0x\h+/, "0xX").sub(/0x\h+/, "0xY")

# raise by class value, with and without a message
anon = Class.new(StandardError) { }
begin
  raise anon, "m"
rescue => e
  p e.message, e.class == anon
end
begin
  raise anon
rescue => e
  p mask(e.message), e.class == anon
end
plain = Class.new(StandardError)
begin
  raise plain, "n"
rescue plain => e
  p e.message
end
begin
  raise plain.new("z")
rescue plain => e
  p e.message
end

# an instance inspects with the class's current print form
k = Class.new(IdentityBase)
p mask(k.new.inspect), mask(k.new.to_s)
k2 = Class.new(IdentityBase) { }
p mask(k2.new.inspect)
Named = k2
p mask(k2.new.inspect), mask(k2.new.to_s)
puts mask(k.new.to_s)

# a boxed anonymous class has no name
vals = [k, 1, "s"]
p vals[0] == k, vals.map(&:class)
p vals[0].name, vals[0].to_s.start_with?("#<Class:0x")
vals = [k2, 1, "s"]
p vals[0].name, vals[0].to_s

# a module cannot be a superclass
module IdentityMod; end
begin
  Class.new(IdentityMod)
rescue TypeError => e
  p e.message
end
begin
  mk = Class.new(Comparable)
  p mk
rescue TypeError => e
  p e.message
end
begin
  Class.new(Kernel) { def x = 1 }
rescue TypeError => e
  p e.message
end
begin
  Mod2 = Class.new(IdentityMod) { def x = 1 }
rescue TypeError => e
  p e.message
end
