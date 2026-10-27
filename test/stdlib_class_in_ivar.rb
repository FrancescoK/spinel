# A `.new` on a stdlib class Spinel does not implement (Pathname, OpenStruct,
# IPAddr, ...) used to silently degrade to an inert 0 -- the object's methods
# then returned nil, so a program that actually used it diverged from CRuby with
# no signal. It now raises NameError instead: if it can't work, it fails loudly.
#
# A class Spinel models as a no-op (Mutex, single-threaded) and user-defined
# classes are unaffected. The ivar slot still compiles either way (the raise
# expression is int-typed, so no undeclared `sp_<Class> *` field is emitted).
#
# ostruct/ipaddr are unimplemented stdlib: under SPINEL_STRICT_REQUIRE the
# `require` itself is a compile error, so a real program omits it and the .new
# still raises NameError at the use site. Mutex is core (no require needed).
#
# Pathname used to stand here too. It is a bundled library now, so naming it
# without requiring it is a compile error that says which require is missing --
# a different (and better) answer than this file is about.

class WithMutex
  def initialize
    @lock = Mutex.new   # special-cased no-op; works
    @n = 5
  end
  def n
    @n
  end
end

class WithIPAddr
  def initialize
    @addr = IPAddr.new('127.0.0.1')   # unsupported stdlib class -> raises here
    @v = 7
  end
  def v
    @v
  end
end

# A Mutex ivar works (single-threaded no-op); another ivar reads fine.
puts WithMutex.new.n          #=> 5

# A user-defined class is unaffected.
class Point
  def initialize(x)
    @x = x
  end
  def x
    @x
  end
end

class Holder
  def initialize
    @p = Point.new(42)
  end
  def px
    @p.x
  end
end

puts Holder.new.px            #=> 42

# Constructing the unsupported-stdlib holder raises (loud), not a silent inert 0.
begin
  WithIPAddr.new
  puts "no raise"
rescue NameError
  puts "ipaddr raised"
end

# A direct `.new` on an unsupported stdlib class raises too.
begin
  OpenStruct.new
  puts "no raise"
rescue NameError
  puts "openstruct raised"
end

puts "done"
