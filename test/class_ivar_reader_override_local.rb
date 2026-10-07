# A local assigned a class method's value follows it when the class ivar
# that method answers widens after inference. `@defs` is written the empty
# literal and `defs + [...]`, and a subclass overrides the reader, so the
# ivar settles only late, from the empty literal's Integer Array to a box.
# `parent = Base.defs` kept the Integer Array: the equality on its element
# was refused, and a read of it raised TypeError at run time (#7602).

class Base
  def self.defs
    @defs
  end

  def self.add
    @defs = defs + [{ keys: ["a", "b"] }]
  end

  def self.clear
    @defs = []
  end

  @defs = []
  add
end

class Child < Base
  def self.defs
    @defs.nil? ? Base.defs : @defs
  end
end

parent = Base.defs
p(parent[0][:keys] == ["a", "b"])
p parent.size
p parent.first

# a block over the local binds the element the local holds now
parent.each { |d| p d }
p parent.select { |d| d[:keys] == ["a", "b"] }.size
p parent.find { |d| d[:keys] }
p parent.any? { |d| d[:keys].size == 2 }
parent.each_with_index { |d, i| p [i + 1, d[:keys]] }

# the subclass's reader, through its nil fallback
child = Child.defs
p child.size
p child.first[:keys]

# a call with an argument, assigned to a local (the bare `p Base.def_at(0)`
# answers right without this change), and one inside a method of another class
class Base
  def self.def_at(i) = defs[i]
end

class Reader
  def run
    got = Base.def_at(0)
    p got[:keys]
    all = Base.defs
    p all.length
  end
end

first = Base.def_at(0)
p first
Reader.new.run
