# `raise Cls, msg` on an exception class with its own initialize is `raise
# Cls.new(msg)`, and the message binds as that call's one argument does. The
# message went to one parameter and every other took its default: an
# initialize taking no argument answered instead of refusing the message
# with the wrong count, a rest took the bare message where CRuby wraps it in
# an Array, a **kwrest was nil where CRuby binds an empty Hash, and a default
# reading an earlier parameter did not build.
def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
class E0 < StandardError
  def initialize = super("e0")
end
class E1 < StandardError
  attr_reader :v
  def initialize(*r) = (@v = [r]; super("e1"))
end
class E2 < StandardError
  attr_reader :v
  def initialize(p1 = 51, *r, **kw) = (@v = [p1, r, kw]; super("e2"))
end
class E3 < StandardError
  attr_reader :v
  def initialize(p1 = 51, p2 = p1) = (@v = [p1, p2]; super("e3"))
end
class E4 < StandardError
  def initialize(a, b) = super("#{a}#{b}")
end
class E5 < StandardError
  def initialize(msg = "dflt") = super(msg.upcase)
end
class E6 < StandardError
  attr_reader :v
  def initialize(m, k: 2) = (@v = [m, k]; super(m))
end
class E7 < E6
end
try { raise E0, 1 }
try { begin; raise E1, 1; rescue E1 => x; x.v; end }
try { begin; raise E2, 1; rescue E2 => x; x.v; end }
try { begin; raise E3, 1; rescue E3 => x; x.v; end }
try { raise E4, 1 }
try { begin; raise E5, "msg"; rescue E5 => x; x.message; end }
try { begin; raise E5; rescue E5 => x; x.message; end }
try { begin; raise E6, "m"; rescue E6 => x; x.v; end }
try { begin; raise E7, "n"; rescue E7 => x; x.v; end }
try { begin; fail E3, 2; rescue E3 => x; x.v; end }
try { begin; raise E3, 4, cause: nil; rescue E3 => x; x.v; end }
