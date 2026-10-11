# A String bang on what a method answers when it answers its argument, an
# element of an Array or a Hash (`id(x[0]).upcase!`), changes the String the
# container holds, which every other name of it sees. Through a boxed
# argument the bang is the boxed one (emit_face_str_bang): its value is the
# element's box, and a chain on it, equal? with it and the mutators after
# it reach the element's String.
def id(v) = v
id(1)

x = [+"ab"]
y = x[0]
id(x[0]).upcase!
p x, y
r = id(x[0]).downcase!
p r, r.equal?(x[0]), r.equal?(y), id(x[0]).downcase!

h = { k: +"cd" }
hv = h[:k]
id(h[:k]).upcase!
p h, hv

class K
  def initialize = (@a = [+"iv"])
  def run
    id(@a[0]).upcase!
    id(@a[0]).downcase!.capitalize!
    @a
  end
  def id(v) = v
end
p K.new.run

z = [+"ef"]
id(z[0])&.upcase!
p z
id(z[0]).downcase!.upcase!.swapcase!
p z
id(z[0]).sub!("e", "q")
id(z[0]).gsub!(/F/) { "g" }
id(z[0]) << "1"
id(z[0]).concat("2")
id(z[0]).insert(0, "<")
id(z[0]).upcase!.concat(">")
p z

t = +"tt"
w = [t]
p id(w[0]).upcase!.equal?(t), t, t.equal?(id(w[0]).downcase!)
p id(t).upcase!.equal?(t), id(t).upcase!.equal?(t.dup)

# a bang chain on a boxed local writes back to the local, which an alias
# of it shares
bx = [+"ab", 1][0]
bx.upcase!.insert(1, "-")
p bx
by = [+"cd", 1][0]
bz = by
by.upcase!.concat("!")
p by, bz
