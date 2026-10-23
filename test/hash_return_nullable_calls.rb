# A Hash built from a nullable number turns poly-valued only after the
# methods it is handed to have bound their parameters to the Integer-valued
# Hash. What a parameter, a block parameter or a returned tuple stores must
# follow it, or its reads take the Integer-valued layout. Every path has its
# own methods, so none widens another's types early.
def pack(value)
  {"n" => value}
end

class Box
  def initialize(h)
    @h = h
  end

  def read
    @h["n"]
  end
end

p Box.new(pack([1][1])).read
p Box.new(pack([1][0])).read

class Setter
  def set(h)
    @h = h
    self
  end

  def read
    @h["n"]
  end
end

p Setter.new.set(pack([1][1])).read

class Base
  def read
    @h["n"]
  end
end

class Derived < Base
  def initialize(h)
    @h = h
  end
end

p Derived.new(pack([1][1])).read

module Keeps
  def keep(h)
    @kept = h
    self
  end

  def kept
    @kept["n"]
  end
end

class Keeper
  include Keeps
end

p Keeper.new.keep(pack([1][1])).kept

def read_yielded(h)
  h["n"]
end

def each_pack(value)
  yield pack(value)
end

each_pack([1][1]) { |h| p read_yielded(h) }

def pair(value)
  return pack(value), 7
end

a, b = pair([1][1])
p a["n"], b

def pack_key(value)
  {value => 1}
end

class KeyBox
  def initialize(h)
    @h = h
  end

  def keys
    @h.keys
  end
end

p KeyBox.new(pack_key([1][1])).keys
p KeyBox.new(pack_key([1][0])).keys
