# spinel: gc-minor
# A module arm's shared, fresh and nil returns use the settled return facts.
# Explicit arguments and omitted defaults take the same boxing route.
module PolyModuleTails
  def answer(mode = 0)
    @calls += 1
    return @text if mode == 0
    return @text + "a" if mode == 1
    @text.length
    nil
  end
end

class PolyModuleTailHolder
  include PolyModuleTails
  attr_reader :calls
  def initialize(text)
    @text = text
    @calls = 0
  end
end

class PolyModuleTailFresh
  def answer(mode = 0) = "fresh".dup
end

source = "s".dup
holder = PolyModuleTailHolder.new(source)
objects = [PolyModuleTailFresh.new, holder]
values = [objects[0].answer, objects[1].answer]
values[1] << "!"
p values, source, holder.calls
values = [objects[1].answer(0), objects[1].answer(1), objects[1].answer(2)]
values[0] << "?"
values[1] << "!"
p values, source, holder.calls
p [values[0].equal?(source), values[1].equal?(source), values[2].nil?]
