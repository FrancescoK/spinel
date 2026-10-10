# bytesplice, append_as_bytes, and concat or prepend with other than one
# argument answer their receiver, as `<<`, one-argument concat and the other
# self-answering mutators do. Kept in an instance variable (an instance's, a
# top-level one, a class-level one, one an attribute writer sets), the result
# is the receiver's String: a change through the instance variable shows in
# the receiver, a change through the receiver shows in it, another method
# reads both, and `equal?` holds.
class Holder
  attr_accessor :s, :r

  def initialize(s) = @s = s

  def read = [@s, @r]
  def same = @r.equal?(@s)
  def grow_receiver = (@s << "?"; @r)

  def keep_lshift = (@r = @s << "x"; @r << "!"; @s)
  def keep_concat1 = (@r = @s.concat("x"); @r << "!"; @s)
  def keep_concat2 = (@r = @s.concat("x", "y"); @r << "!"; @s)
  def keep_concat0 = (@r = @s.concat; @r << "!"; @s)
  def keep_prepend1 = (@r = @s.prepend("p"); @r << "!"; @s)
  def keep_prepend2 = (@r = @s.prepend("p", "q"); @r << "!"; @s)
  def keep_prepend0 = (@r = @s.prepend; @r << "!"; @s)
  def keep_insert = (@r = @s.insert(1, "I"); @r << "!"; @s)
  def keep_replace = (@r = @s.replace("zz"); @r << "!"; @s)
  def keep_clear = (@r = @s.clear; @r << "!"; @s)
  def keep_force_encoding = (@r = @s.force_encoding("UTF-8"); @r << "!"; @s)
  def keep_itself = (@r = @s.itself; @r << "!"; @s)
  def keep_to_s = (@r = @s.to_s; @r << "!"; @s)
  def keep_bytesplice = (@r = @s.bytesplice(0, 1, "Z"); @r << "!"; @s)
  def keep_append_as_bytes = (@r = @s.append_as_bytes("i", "j"); @r << "!"; @s)
end

h = Holder.new(+"abc")
p [:lshift, h.keep_lshift]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:concat1, h.keep_concat1]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:concat2, h.keep_concat2]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:concat0, h.keep_concat0]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:prepend1, h.keep_prepend1]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:prepend2, h.keep_prepend2]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:prepend0, h.keep_prepend0]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:insert, h.keep_insert]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:replace, h.keep_replace]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:clear, h.keep_clear]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:force_encoding, h.keep_force_encoding]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:itself, h.keep_itself]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:to_s, h.keep_to_s]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:bytesplice, h.keep_bytesplice]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]
h = Holder.new(+"abc")
p [:append_as_bytes, h.keep_append_as_bytes]
p [h.read, h.same]
p [h.grow_receiver, h.read, h.same]

# an instance variable of the top level
@t = +"abc"
@u = @t << "x"
@u << "!"
p [:top_lshift, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.concat("x")
@u << "!"
p [:top_concat1, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.concat("x", "y")
@u << "!"
p [:top_concat2, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.concat
@u << "!"
p [:top_concat0, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.prepend("p")
@u << "!"
p [:top_prepend1, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.prepend("p", "q")
@u << "!"
p [:top_prepend2, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.prepend
@u << "!"
p [:top_prepend0, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.insert(1, "I")
@u << "!"
p [:top_insert, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.replace("zz")
@u << "!"
p [:top_replace, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.clear
@u << "!"
p [:top_clear, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.force_encoding("UTF-8")
@u << "!"
p [:top_force_encoding, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.itself
@u << "!"
p [:top_itself, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.to_s
@u << "!"
p [:top_to_s, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.bytesplice(0, 1, "Z")
@u << "!"
p [:top_bytesplice, @t, @u, @u.equal?(@t)]
@t = +"abc"
@u = @t.append_as_bytes("i", "j")
@u << "!"
p [:top_append_as_bytes, @t, @u, @u.equal?(@t)]

# an instance variable of a class
class Level
  @cs = nil
  @cr = nil

  def self.keep_lshift
    @cs = +"abc"
    @cr = @cs << "x"
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_concat1
    @cs = +"abc"
    @cr = @cs.concat("x")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_concat2
    @cs = +"abc"
    @cr = @cs.concat("x", "y")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_concat0
    @cs = +"abc"
    @cr = @cs.concat
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_prepend1
    @cs = +"abc"
    @cr = @cs.prepend("p")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_prepend2
    @cs = +"abc"
    @cr = @cs.prepend("p", "q")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_prepend0
    @cs = +"abc"
    @cr = @cs.prepend
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_insert
    @cs = +"abc"
    @cr = @cs.insert(1, "I")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_replace
    @cs = +"abc"
    @cr = @cs.replace("zz")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_clear
    @cs = +"abc"
    @cr = @cs.clear
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_force_encoding
    @cs = +"abc"
    @cr = @cs.force_encoding("UTF-8")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_itself
    @cs = +"abc"
    @cr = @cs.itself
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_to_s
    @cs = +"abc"
    @cr = @cs.to_s
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_bytesplice
    @cs = +"abc"
    @cr = @cs.bytesplice(0, 1, "Z")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
  def self.keep_append_as_bytes
    @cs = +"abc"
    @cr = @cs.append_as_bytes("i", "j")
    @cr << "!"
    [@cs, @cr, @cr.equal?(@cs)]
  end
end
p [:class_lshift, Level.keep_lshift]
p [:class_concat1, Level.keep_concat1]
p [:class_concat2, Level.keep_concat2]
p [:class_concat0, Level.keep_concat0]
p [:class_prepend1, Level.keep_prepend1]
p [:class_prepend2, Level.keep_prepend2]
p [:class_prepend0, Level.keep_prepend0]
p [:class_insert, Level.keep_insert]
p [:class_replace, Level.keep_replace]
p [:class_clear, Level.keep_clear]
p [:class_force_encoding, Level.keep_force_encoding]
p [:class_itself, Level.keep_itself]
p [:class_to_s, Level.keep_to_s]
p [:class_bytesplice, Level.keep_bytesplice]
p [:class_append_as_bytes, Level.keep_append_as_bytes]

# an instance variable an attribute writer sets
h = Holder.new(+"abc")
h.r = h.s << "x"
h.r << "!"
p [h.s, h.r.equal?(h.s)]
h = Holder.new(+"abc")
h.r = h.s.concat("x", "y")
h.r << "!"
p [h.s, h.r.equal?(h.s)]
h = Holder.new(+"abc")
h.r = h.s.prepend("p", "q")
h.r << "!"
p [h.s, h.r.equal?(h.s)]
h = Holder.new(+"abc")
h.r = h.s.insert(1, "I")
h.r << "!"
p [h.s, h.r.equal?(h.s)]

# a frozen receiver raises, and the instance variable keeps nothing
class Frozen
  def initialize(s) = @s = s
  def concat2 = (@r = @s.concat("x", "y"); @r << "!")
  def prepend2 = (@r = @s.prepend("p", "q"); @r << "!")
  def bytesplice = (@r = @s.bytesplice(0, 1, "Z"); @r << "!")
  def append_as_bytes = (@r = @s.append_as_bytes("i", "j"); @r << "!")
  def kept = @r
end
%i[concat2 prepend2 bytesplice append_as_bytes].each do |m|
  z = Frozen.new("abc".freeze)
  begin
    z.send(m)
  rescue FrozenError
    p [m, :frozen, z.kept]
  end
end

# arguments that are computed (a call's result, a new String) rather than
# literals or reads: the call is the receiver's String all the same, the
# receiver being taken ahead of its arguments, as when an argument is a
# method that sets the instance variable. bytesplice is the control, a call
# whose arguments were always taken in order.
def mk(i) = "m#{i}"
class Computed
  def initialize(s) = @s = s

  def read = [@s, @r]
  def same = @r.equal?(@s)

  def insert_upcase(x) = (@r = @s.insert(0, x.upcase); @r << "!"; @s)
  def insert_to_s(i) = (@r = @s.insert(1, i.to_s); @r << "!"; @s)
  def insert_plus(x, y) = (@r = @s.insert(0, x + y); @r << "!"; @s)
  def insert_dup(x) = (@r = @s.insert(0, x.dup); @r << "!"; @s)
  def insert_method(i) = (@r = @s.insert(0, mk(i)); @r << "!"; @s)
  def swap(x) = (@s = +"zz"; x.upcase)
  def insert_rebound(x) = (@r = @s.insert(0, swap(x)); @r << "!"; @s)
  def bytesplice_rebound(x) = (@r = @s.bytesplice(0, 1, swap(x)); @r << "!"; @s)
  def concat_rebound(x) = (@r = @s.concat(swap(x), "y"); @r << "!"; @s)
  def insert_block
    3.times { |i| @r = @s.insert(0, i.to_s); @r << "!" }
    @s
  end
  def bytesplice_upcase(x) = (@r = @s.bytesplice(0, 1, x.upcase); @r << "!"; @s)
  def bytesplice_to_s(i) = (@r = @s.bytesplice(0, 1, i.to_s); @r << "!"; @s)
  def bytesplice_method(i) = (@r = @s.bytesplice(0, 1, mk(i)); @r << "!"; @s)
  def concat_upcase(x) = (@r = @s.concat(x.upcase, mk(1)); @r << "!"; @s)
  def prepend_upcase(x) = (@r = @s.prepend(x.upcase, mk(2)); @r << "!"; @s)
  def append_as_bytes_upcase(x) = (@r = @s.append_as_bytes(x.upcase, mk(3)); @r << "!"; @s)
end
[[:insert_upcase, "q"], [:insert_to_s, 7], [:insert_plus, "p", "q"], [:insert_dup, "q"],
 [:insert_method, 4], [:insert_rebound, "q"], [:bytesplice_rebound, "q"], [:concat_rebound, "q"],
 [:insert_block], [:bytesplice_upcase, "q"],
 [:bytesplice_to_s, 7], [:bytesplice_method, 4], [:concat_upcase, "q"], [:prepend_upcase, "q"],
 [:append_as_bytes_upcase, "q"]].each do |m, *args|
  c = Computed.new(+"abc")
  p [m, c.send(m, *args)]
  p [c.read, c.same]
end

# the same at the top level and in a block
@cs = +"abc"
x = "q"
@cr = @cs.insert(0, x.upcase)
@cr << "!"
p [:top_insert_upcase, @cs, @cr, @cr.equal?(@cs)]
@cs = +"abc"
@cr = @cs.insert(1, 5.to_s)
@cr << "!"
p [:top_insert_to_s, @cs, @cr, @cr.equal?(@cs)]
@cs = +"abc"
@cr = @cs.insert(0, mk(6))
@cr << "!"
p [:top_insert_method, @cs, @cr, @cr.equal?(@cs)]
@cs = +"abc"
@cr = @cs.bytesplice(0, 1, x.upcase)
@cr << "!"
p [:top_bytesplice_upcase, @cs, @cr, @cr.equal?(@cs)]
@cs = +"abc"
2.times do |i|
  @cr = @cs.insert(0, i.to_s)
  @cr << "!"
end
p [:block_insert_to_s, @cs, @cr, @cr.equal?(@cs)]
@cs = +"abc"
2.times do |i|
  @cr = @cs.bytesplice(0, 1, i.to_s)
  @cr << "!"
end
p [:block_bytesplice_to_s, @cs, @cr, @cr.equal?(@cs)]
