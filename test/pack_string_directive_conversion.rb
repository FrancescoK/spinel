# A String directive of Array#pack (a A Z B b H h m u M) converts its
# element as CRuby does. a A Z B b H h m u take a String, or an object's
# #to_str; nil is no bytes for the first seven, which pad it, and a
# TypeError for m and u; anything else is "no implicit conversion of
# Integer into String". M takes any value's #to_s.
#
# An element that was no String read as no bytes, so [1].pack("a*")
# answered "" and [1].pack("a") a NUL, on a typed Integer or Float Array
# as on a poly one; a shared String handle in a poly Array read as none
# too; and M packed every non-String as "".

def t(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue TypeError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

class K; end
class S
  def to_str = "zz"
end
class T
  def to_s = "tt"
end

ints = [1, 2]
flts = [1.5]
objs = [K.new]
syms = [:s]
poly = [1, "a"]
arrs = [[1]]
nils = [nil]
strs = ["ab"]

%w[a* A* Z* a A Z a3 B b H h m m0 u].each do |f|
  [["ints", ints], ["flts", flts], ["objs", objs], ["syms", syms], ["poly", poly],
   ["arrs", arrs], ["nils", nils], ["strs", strs]].each do |name, r|
    t("#{name}.pack(#{f})") { r.pack(f) }
  end
end

# M: any value's #to_s
t("M ints") { ints.pack("M") }
t("M flts") { flts.pack("M") }
t("M syms") { syms.pack("M") }
t("M poly") { poly.pack("MM") }
t("M arrs") { arrs.pack("M") }
t("M nils") { nils.pack("M") }
t("M to_s") { [T.new].pack("M") }

# #to_str converts, #to_s does not
t("to_str a*") { [S.new].pack("a*") }
t("to_str m") { [S.new].pack("m") }
t("to_s a") { [T.new].pack("a") }
t("true a") { [true].pack("a") }

# a typed Array's nil
i = [1, 2]; i[0] = nil
t("int nil a2") { i.pack("a2C") }
t("int nil m") { i.pack("m") }
f = [1.5, 2.5]; f[0] = nil
t("flt nil A2") { f.pack("A2") }
t("flt nil u") { f.pack("u") }
s = ["ab", "cd"]; s[0] = nil
t("str nil Z*") { s.pack("Z*a*") }
t("str nil m") { s.pack("m") }

# mixed formats
t("C a") { [1, 2].pack("Ca") }
t("a C") { ["x", 2].pack("aC") }
t("a a") { ["x", 2].pack("aa") }
t("N a*") { [1, 2].pack("Na*") }
t("a* N") { ["ab", 3].pack("a*N") }
t("H* C") { ["4a", 5].pack("H*C") }

# a shared String handle in a poly Array
h = +"ab"
h << "cd"
mixed = [h, 1]
p mixed.pack("a*C"), mixed.pack("a3"), mixed.pack("m"), mixed.pack("M"), mixed.pack("H*")

# a boxed receiver
[[1, 2], [1.5], ["ab"], [:s, 1]].each do |v|
  t("boxed #{v.inspect}") { v.pack("a*") }
end
