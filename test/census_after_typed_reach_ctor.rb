# A class reached code is typed with opens its instances only in the last
# reachability pass (Sel, built where nothing runs), and its initialize,
# now reached, builds a Ctx: the census runs again on that pass, so Ctx's
# constructor is written (#10643, openssl's SSLSocket#initialize and
# SSLContext.new).
class Ctx
  def initialize
    @v = 1
  end
  def v = @v
end

class Sel
  def initialize(k, ctx = nil)
    @k = k
    @ctx = ctx.nil? ? Ctx.new : ctx
  end

  def kind
    @k
  end
end

class Frag
  def self.parse(t)
    Sel.new(t)
  end

  def self.matches?(m)
    m.kind == "all"
  end
end

class Z
  def self.go
    Frag.matches?(Sel.new("all"))
  end
end

class Entry
  def matches?(name)
    name == "x"
  end
end

list = [Entry.new]
p list[0].matches?("x")
p Frag.name
