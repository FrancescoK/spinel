# Class-body macros that keep state in the class: one call sets an ivar, a
# later one reads it to build a name. The compiler follows that state through
# the statements of the class body -- and gives up where it cannot.
module Consts
  def kind(k = nil)
    return @kind if k.nil?
    @kind = k
  end

  def constant(c, name: c, fallback: nil)
    fn = ["calc", kind, c.to_s.downcase].compact.join("_")
    const_set(name, public_send(fn))
  end
end

class Calc
  extend Consts
  def self.calc_box_size = 32
  def self.calc_box_nonce = 24
  kind :box
  constant :SIZE
  constant :NONCE, name: :NONCE_BYTES
  def self.info = [SIZE, NONCE_BYTES]
end
p Calc.info, Calc.kind

# the state is each class's own, and lasts across its reopened bodies
class Small
  extend Consts
  def self.calc_small_size = 4
  kind :small
end
class Small
  constant :SIZE
end
p Small::SIZE, Small.kind

# branches that agree leave the state known
class Agree
  extend Consts
  def self.calc_box_size = 8
  if RUBY_VERSION >= "3"
    kind :box
  else
    kind :box
  end
  constant :SIZE
end
p Agree::SIZE

# macro calls in a branch, whose state nothing after them reads
class Branched
  extend Consts
  def self.calc_box_a = 1
  if RUBY_VERSION >= "3"
    kind :box
    constant :A
  end
end
p Branched::A

# a macro under a modifier
class Guarded
  extend Consts
  def self.calc_box_g = 16
  kind :box
  constant :G if RUBY_VERSION >= "3"
end
p Guarded::G

# a macro that reads the state without writing it: a call from a method,
# with no arguments, is not a write
module Prim
  def prim_type(type = nil)
    return @type if type.nil?
    @type = type
  end

  def prim_primitive(primitive = nil)
    if primitive.nil?
      @primitive if defined?(@primitive)
    else
      @primitive = primitive
    end
  end

  def primitive = prim_primitive

  def prim_constant(c, name: c)
    const_set(name, public_send(["crypto", prim_type, prim_primitive, c.to_s.downcase].compact.join("_")))
  end
end

class Keyed
  extend Prim
  def self.crypto_box_curve_keybytes = 32
  if RUBY_VERSION >= "3"
    prim_type :box
    prim_primitive :curve
    prim_constant :KEYBYTES
  end
  def primitive = self.class.primitive
end
p Keyed::KEYBYTES, Keyed.new.primitive
