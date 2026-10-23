# A Hash built from a nullable number turns poly-valued only after the
# variables and constants it is written to have settled on the
# Integer-valued Hash. Each must follow it, or its reads take the
# Integer-valued layout. Every path has its own methods, so none widens
# another's types early.
def pack(value)
  {"n" => value}
end

class Direct
  def put(value)
    @h = pack(value)
    self
  end

  def cache(value)
    @c ||= pack(value)
  end

  def read
    @h["n"]
  end
end

p Direct.new.put([1][1]).read
p Direct.new.put([1][0]).read
p Direct.new.cache([1][1])

Entry = Struct.new(:h)
entry = Entry.new({"n" => 2})
entry.h = pack([1][1])
p entry.h["n"]

class Registry
  def self.put(value)
    @@h = pack(value)
  end

  def self.read
    @@h["n"]
  end
end

Registry.put([1][1])
p Registry.read

def put_global(value)
  $h = pack(value)
end

put_global([1][1])
p $h["n"]

NIL_N = pack([1][1])
ONE_N = pack([1][0])
p NIL_N["n"], ONE_N["n"]

c, d = pack([1][1]), 8
p c["n"], d

case pack([1][1])
in Hash => matched then p matched["n"]
end
