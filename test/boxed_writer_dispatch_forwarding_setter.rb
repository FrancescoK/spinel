# A setter call on a receiver of more than one class (`obj.formatter = v`
# with obj an attr_accessor class or one whose `formatter=` forwards
# `(...)`): the forwarding setter takes the value as its rest, as a direct
# call hands it -- concrete value or boxed.
class Plain
  attr_accessor :formatter
end

class Fan
  def initialize = @got = []
  def dispatch(name, *args, **kw, &block) = (@got << [name, *args]; block ? block.call : args.first)
  def formatter=(...)
    dispatch(:formatter=, ...)
  end
  def level=(*levels)
    @got << [:level=, *levels]
  end
  attr_reader :got
end

class Lvl
  attr_accessor :level
end

def set_on(obj, v)
  obj.formatter = v
  nil
end

def set_sym(obj)
  obj.formatter = :sym
  nil
end

def set_level(obj, v)
  obj.level = v
  nil
end

f = Fan.new
pl = Plain.new
f.formatter = :direct
set_on(pl, :fmt)
set_on(f, 42)
set_sym(pl)
set_sym(f)
set_level(Lvl.new, 1)
set_level(f, "warn")
p pl.formatter, f.got
