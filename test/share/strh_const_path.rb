# spinel: share
# spinel: gc-minor
# A constant named to const_get by a path (H::L): every constant is reached
# by a name the program computes, so an Array it holds keeps the general form.
# a constant named by a path
class H
  L = [+"s"]
  def self.add(t) = L << t
  def self.show = p(L)
end
s9 = +"u"
H.add(s9)
Object.const_get("H::L")[0] << "?"
s9 << "!"
H.show
x9 = Object.const_get("H::L")
x9 << +"v"
p x9.size
class Holder
  S = +"s"
  L = [S]
  def self.add(t) = L << t
  def self.show = p(L)
end
Holder.add(+"t")
Object.const_get("Holder::L") << 64
Object.const_get("Holder::L")[0] << "?"
Holder::S << "!"
Holder.show

# beside it an Array nothing here touches keeps the handle form
u = +"u"
plain = [u, +"o"]
plain << +"p"
plain.each { |e| e << "." }
u << "?"
p plain, u
