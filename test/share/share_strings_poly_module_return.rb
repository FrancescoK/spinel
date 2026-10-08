# spinel: gc-minor
# Polymorphic module methods return the same String their ivar holds.
# Fresh neighbouring arms retain their own mutable String too.
class PolyModuleFresh
  def initialize(text) = @text = text
  def plus = @text + "a"
end

module PolyModuleRead
  def plus = @text
end

class PolyModuleIncluded
  include PolyModuleRead
  def initialize(text) = @text = text
end

class PolyModulePrepended
  prepend PolyModuleRead
  def initialize(text) = @text = text
  def plus = @text + "unused"
end

source = "s".dup
objects = [PolyModuleFresh.new("s".dup), PolyModuleIncluded.new(source)]
values = [objects[0].plus, objects[1].plus]
values[1] << "!"
p values, source
values[0] << "?"
p values, source
p values[1].equal?(source)

binary = "b\0c".b.dup
objects = [PolyModuleFresh.new("p".dup), PolyModulePrepended.new(binary)]
values = [objects[0].plus, objects[1].plus]
values[1] << "!"
p values, binary, values[1].equal?(binary), values[1].encoding

objects = [PolyModuleFresh.new("f".dup), PolyModuleIncluded.new("frozen")]
values = [objects[0].plus, objects[1].plus]
begin
  values[1] << "!"
rescue FrozenError
  puts "frozen"
end
p values
