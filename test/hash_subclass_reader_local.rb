# A local that holds what a reader of a Hash subclass answers keeps the
# Hash type. The instance starts with its Hash by value, so the local
# reads it as it is. A last check widened such a local to a box after
# the share rule ran. The String key that went into the box was then
# refused as shared (#9258).
Pair = Struct.new(:l, :r)
p Pair.new(1, 2).r

class Map < Hash
end

class Holder
  attr_reader :long

  def initialize
    @long = Map.new
  end
end

class Switch
  attr_reader :long

  def initialize(long)
    @long = long
  end
end

flag = +"--y"
switch = Switch.new(flag)
flag << "z"
p switch.long

class Parser
  TABLE = {"help" => proc { 1 }, "version" => proc { 2 }}

  def initialize
    @stack = [Holder.new, Holder.new]
  end

  def base
    @stack[1]
  end

  def fill
    holder = base
    TABLE.each do |name, block|
      holder.long[name] ||= block.call
    end
    holder.long
  end
end

p Parser.new.fill
