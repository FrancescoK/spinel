# An empty Array handed to a parameter an --rbs signature gives a typed Array
# (Array[String], Array[Integer]) is built in the parameter's element type, as
# every wrapper of it is: parentheses, begin/end, a ternary arm, `.freeze`, a
# bare `Array.new` (also `Array.new()` and `Array.new(0)`). An empty Hash
# (`{}`, `({})`, `Hash.new`, `(Hash.new)`) is built the same for a
# Hash[String, Integer] parameter. Each is handed to a positional, a required
# keyword, an optional keyword and an optional positional parameter, as a
# default of one, and to an initialize. The empty argument was built as an
# IntArray when parenthesised, and as the general Array when it was
# `Array.new`, and the C stopped on the pointer types. The callee pushes into
# a copy, so the element type is seen at run time. An empty literal in
# parentheses as an arm of a conditional that joins another arm is the same.
module RbsEmptyArgStr
  def self.pos(a, b)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.req(a, b:)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.opt(a, b: [])
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.dflt(a, b = [])
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.dflt_paren(a, b = ([]))
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.dflt_new(a, b = Array.new)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.kw_new(a, b: Array.new)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
end
class RbsEmptyArgStrK
  def initialize(a, b = ([]), c: Array.new)
    @a = a
    @b = b
    @c = c
  end
  def show
    @b << @a[0]
    @c << @a[0]
    p @b, @c
  end
end
a = [+"l"]
p RbsEmptyArgStr.pos(a, [])
p RbsEmptyArgStr.pos(a, ([]))
p RbsEmptyArgStr.pos(a, (1; []))
p RbsEmptyArgStr.pos(a, begin; []; end)
p RbsEmptyArgStr.pos(a, [].freeze)
p RbsEmptyArgStr.pos(a, ([].freeze))
p RbsEmptyArgStr.pos(a, Array.new)
p RbsEmptyArgStr.pos(a, Array.new())
p RbsEmptyArgStr.pos(a, Array.new(0))
p RbsEmptyArgStr.pos(a, (Array.new))
p RbsEmptyArgStr.pos(a, (a.size > 5 ? a : []))
p RbsEmptyArgStr.req(a, b: ([]))
p RbsEmptyArgStr.opt(a, b: ([]))
p RbsEmptyArgStr.kw_new(a, b: ([]))
p RbsEmptyArgStr.dflt(a, ([]))
p RbsEmptyArgStr.dflt_paren(a, ([]))
p RbsEmptyArgStr.dflt_new(a, ([]))
p RbsEmptyArgStr.req(a, b: Array.new)
p RbsEmptyArgStr.opt(a, b: Array.new)
p RbsEmptyArgStr.kw_new(a, b: Array.new)
p RbsEmptyArgStr.dflt(a, Array.new)
p RbsEmptyArgStr.dflt_paren(a, Array.new)
p RbsEmptyArgStr.dflt_new(a, Array.new)
p RbsEmptyArgStr.req(a, b: (Array.new))
p RbsEmptyArgStr.opt(a, b: (Array.new))
p RbsEmptyArgStr.kw_new(a, b: (Array.new))
p RbsEmptyArgStr.dflt(a, (Array.new))
p RbsEmptyArgStr.dflt_paren(a, (Array.new))
p RbsEmptyArgStr.dflt_new(a, (Array.new))
p RbsEmptyArgStr.opt(a)
RbsEmptyArgStr.dflt(a)
RbsEmptyArgStr.dflt_paren(a)
p RbsEmptyArgStr.dflt_new(a)
p RbsEmptyArgStr.kw_new(a)
RbsEmptyArgStrK.new(a).show
RbsEmptyArgStrK.new(a, ([])).show
RbsEmptyArgStrK.new(a, Array.new, c: ([])).show
RbsEmptyArgStrK.new(a, c: Array.new).show

module RbsEmptyArgInt
  def self.pos(a, b)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.req(a, b:)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.opt(a, b: [])
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.dflt(a, b = [])
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.dflt_paren(a, b = ([]))
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.dflt_new(a, b = Array.new)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
  def self.kw_new(a, b: Array.new)
    x = b.dup
    x << a[0]
    p x
    b.size + a.size
  end
end
class RbsEmptyArgIntK
  def initialize(a, b = ([]), c: Array.new)
    @a = a
    @b = b
    @c = c
  end
  def show
    @b << @a[0]
    @c << @a[0]
    p @b, @c
  end
end
a = [7]
p RbsEmptyArgInt.pos(a, [])
p RbsEmptyArgInt.pos(a, ([]))
p RbsEmptyArgInt.pos(a, (1; []))
p RbsEmptyArgInt.pos(a, begin; []; end)
p RbsEmptyArgInt.pos(a, [].freeze)
p RbsEmptyArgInt.pos(a, ([].freeze))
p RbsEmptyArgInt.pos(a, Array.new)
p RbsEmptyArgInt.pos(a, Array.new())
p RbsEmptyArgInt.pos(a, Array.new(0))
p RbsEmptyArgInt.pos(a, (Array.new))
p RbsEmptyArgInt.pos(a, (a.size > 5 ? a : []))
p RbsEmptyArgInt.req(a, b: ([]))
p RbsEmptyArgInt.opt(a, b: ([]))
p RbsEmptyArgInt.kw_new(a, b: ([]))
p RbsEmptyArgInt.dflt(a, ([]))
p RbsEmptyArgInt.dflt_paren(a, ([]))
p RbsEmptyArgInt.dflt_new(a, ([]))
p RbsEmptyArgInt.req(a, b: Array.new)
p RbsEmptyArgInt.opt(a, b: Array.new)
p RbsEmptyArgInt.kw_new(a, b: Array.new)
p RbsEmptyArgInt.dflt(a, Array.new)
p RbsEmptyArgInt.dflt_paren(a, Array.new)
p RbsEmptyArgInt.dflt_new(a, Array.new)
p RbsEmptyArgInt.req(a, b: (Array.new))
p RbsEmptyArgInt.opt(a, b: (Array.new))
p RbsEmptyArgInt.kw_new(a, b: (Array.new))
p RbsEmptyArgInt.dflt(a, (Array.new))
p RbsEmptyArgInt.dflt_paren(a, (Array.new))
p RbsEmptyArgInt.dflt_new(a, (Array.new))
p RbsEmptyArgInt.opt(a)
RbsEmptyArgInt.dflt(a)
RbsEmptyArgInt.dflt_paren(a)
p RbsEmptyArgInt.dflt_new(a)
p RbsEmptyArgInt.kw_new(a)
RbsEmptyArgIntK.new(a).show
RbsEmptyArgIntK.new(a, ([])).show
RbsEmptyArgIntK.new(a, Array.new, c: ([])).show
RbsEmptyArgIntK.new(a, c: Array.new).show

module RbsEmptyArgHash
  def self.pos(a, h)
    x = h.dup
    x[a] = 1
    p x
    h.size
  end
  def self.req(a, h:)
    x = h.dup
    x[a] = 2
    p x
    h.size
  end
  def self.opt(a, h: {})
    x = h.dup
    x[a] = 3
    p x
    h.size
  end
  def self.dflt(a, h = ({}))
    x = h.dup
    x[a] = 4
    p x
    h.size
  end
  def self.dflt_new(a, h = Hash.new)
    x = h.dup
    x[a] = 5
    p x
    h.size
  end
end
class RbsEmptyArgHashK
  def initialize(a, h = ({}), g: Hash.new)
    @h = h
    @g = g
    @h[a] = 1
    @g[a] = 2
  end
  def show
    p @h, @g
  end
end
p RbsEmptyArgHash.pos("k", {})
p RbsEmptyArgHash.req("k", h: {})
p RbsEmptyArgHash.opt("k", h: {})
p RbsEmptyArgHash.dflt("k", {})
p RbsEmptyArgHash.dflt_new("k", {})
p RbsEmptyArgHash.pos("k", ({}))
p RbsEmptyArgHash.req("k", h: ({}))
p RbsEmptyArgHash.opt("k", h: ({}))
p RbsEmptyArgHash.dflt("k", ({}))
p RbsEmptyArgHash.dflt_new("k", ({}))
p RbsEmptyArgHash.pos("k", Hash.new)
p RbsEmptyArgHash.req("k", h: Hash.new)
p RbsEmptyArgHash.opt("k", h: Hash.new)
p RbsEmptyArgHash.dflt("k", Hash.new)
p RbsEmptyArgHash.dflt_new("k", Hash.new)
p RbsEmptyArgHash.pos("k", (Hash.new))
p RbsEmptyArgHash.req("k", h: (Hash.new))
p RbsEmptyArgHash.opt("k", h: (Hash.new))
p RbsEmptyArgHash.dflt("k", (Hash.new))
p RbsEmptyArgHash.dflt_new("k", (Hash.new))
p RbsEmptyArgHash.opt("k")
p RbsEmptyArgHash.dflt("k")
p RbsEmptyArgHash.dflt_new("k")
RbsEmptyArgHashK.new("k").show
RbsEmptyArgHashK.new("k", ({})).show
RbsEmptyArgHashK.new("k", Hash.new, g: ({})).show
RbsEmptyArgHashK.new("k", g: Hash.new).show

module RbsEmptyArgArm
  def self.pos(a, b)
    x = b.dup
    x << a[0]
    p x
    b.size
  end
end
$rbs_empty_arm = true
p RbsEmptyArgArm.pos([+"a"], $rbs_empty_arm ? ([]) : nil)
p RbsEmptyArgArm.pos([+"b"], $rbs_empty_arm ? ([]) : [+"z"])
p RbsEmptyArgArm.pos([+"c"], $rbs_empty_arm ? Array.new : [+"z"])
