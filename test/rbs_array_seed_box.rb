# spinel: needs-rbs-parser
# An Array an RBS signature declares (a return, a parameter) whose value is
# a box: a read out of a Hash of mixed values, holding an Array built with
# mixed values that holds only Integers. The value stays the object it is,
# checked to be an Array when it returns; unboxed into the seed's form it
# was a copy, and a change through one name was not seen through the other.
CONF = { "a" => [1, "s"].select { |x| x.is_a?(Integer) }, "b" => "x", "n" => nil }

class Cfg
  #: (String) -> Array[Integer]
  def for(key) = CONF[key]

  #: (String) -> Array[Integer]?
  def maybe(key) = CONF[key]

  #: (Array[Integer]) -> Array[Integer]
  def push9(a)
    a << 9
    a
  end

  #: (Array[Integer]) -> void
  def keep(a)
    @kept = a
  end

  #: () -> Array[Integer]
  def kept = @kept
end

c = Cfg.new
a = c.for("a")
a << 8
p CONF["a"], a.equal?(CONF["a"])
p c.maybe("n")
y = c.push9(CONF["a"])
p CONF["a"], y.equal?(CONF["a"])
c.keep(CONF["a"])
c.kept << 7
p CONF["a"]
