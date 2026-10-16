# `@bytes += size` on a poly ivar has an arm for the user class whose `+`
# a signature types (String other) and the numeric arm. The argument is
# converted for the user arm only: the numeric arm takes the value as it is.
# The Integer was converted to the String parameter for both, and the C did
# not build; a boxed size raised TypeError in the numeric arm (#9131).
class AppPath
  def initialize(s)
    @s = s
  end

  def +(other)
    AppPath.new(@s + "/" + other)
  end

  def to_s = @s
end

class Cache
  def initialize
    @entries = {}
    @bytes = 0
  end

  def write(key, value)
    size = key.bytesize + 10
    while @entries.size > 5
      _, (_, removed_size) = @entries.shift
      @bytes -= removed_size
    end
    @entries[key] = [value, size]
    @bytes += size
  end

  def bytes = @bytes
end

AppPath.new("a") + "b"
c = Cache.new
c.write("k", { body: "x" })
8.times { |i| c.write("key#{i}", { body: i }) }
p c.bytes

class Holder
  def initialize(v)
    @v = v
  end

  def add(x)
    @v += x
    self
  end

  def v = @v
end

p Holder.new(5).add([1, 2][ARGV.size]).v
p Holder.new(AppPath.new("root")).add("leaf").v.to_s
