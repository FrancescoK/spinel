# dup and clone of a String that is a shared handle (#6179) copy it: an
# append to the copy leaves the original alone, dup is never frozen and
# clone keeps the original's frozen state unless freeze: says otherwise.
# Boxed -- a proc or lambda parameter, an Array element, a parameter that
# also takes an Integer -- the handle came back as itself (sp_poly_dup had
# no arm for it), so the "copy" was the original. A handle local's clone
# read the frozen flag off a fresh copy of its text, which never has it.

pr = proc do |t|
  d = t.dup
  d << "D"
  c = t.clone
  c << "C"
  p d.equal?(t), c.equal?(t)
  t << "!"
end
s = +"ab"
pr.call(s)
p s

la = ->(t) { t << "!"; t.freeze; [t.clone.frozen?, t.dup.frozen?, t.clone(freeze: false).frozen?] }
p la.(+"cd")

def app(x) = x << "!"
arr = [+"ef"]
app(arr[0])
c = arr[0].clone
c << "C"
d = arr[0].dup
d << "D"
p arr[0], c, d
arr[0].freeze
p arr[0].clone.frozen?, arr[0].dup.frozen?
u = arr[0].clone(freeze: false)
u << "U"
p u, u.frozen?, arr[0]

def pick(v) = (v << "?"; v.dup)
w = +"gh"
x = pick(w)
x << "X"
p w, x
pick(1) if ARGV.size > 5 rescue nil

# the binary tag comes with the copy
b = [+"\xff\x00"]
b[0].force_encoding(Encoding::BINARY)
app(b[0])
p b[0].dup.encoding == Encoding::BINARY, b[0].clone.size

# a handle local, frozen in place
h = +"ij"
pr.call(h)
h.freeze
p h.clone.frozen?, h.dup.frozen?, h.clone(freeze: true).frozen?
