# A slot holding either a user module (as a value) or an instance of a class
# dispatches the module side to the method `module_function def` defines.
module Rend
  module_function def draw_machine(m) = [m]
end

class Alt
  def draw_machine(m) = [:alt, m]
end

class Mm
  attr_writer :r
  def rend = @r || Rend
  def draw = rend.draw_machine(1)
end

p Mm.new.draw
x = Mm.new
x.r = Alt.new
p x.draw
p Rend.draw_machine(2)

# a keyword param with a default, the call passing no keywords
module KwRend
  module_function def show(m, io: 1) = [m, io]
end

class KwAlt
  def show(m, io: 2) = [:alt, m, io]
end

class KwHolder
  attr_writer :r
  def rend = @r || KwRend
  def run = rend.show(3)
end

p KwHolder.new.run
k = KwHolder.new
k.r = KwAlt.new
p k.run

# `def self.m` on a module, and on a class, held the same way
module SelfRend
  def self.draw_machine(m) = [:mod, m]
end

class ClsRend
  def self.draw_machine(m) = [:cls, m]
end

class Holder
  def initialize(r) = @r = r
  def draw = @r.draw_machine(4)
end

p Holder.new(SelfRend).draw
p Holder.new(ClsRend).draw
p Holder.new(Alt.new).draw

# the instance copy module_function leaves behind still serves an includer
class Includer
  include Rend
  def go = draw_machine(5)
end
p Includer.new.go
