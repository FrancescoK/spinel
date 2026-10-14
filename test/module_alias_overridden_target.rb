# An alias a module makes of its own method keeps the module's body when the
# class that includes it overrides the method, as CRuby's alias does.

module Tr
  def on_b = "Tr#on_b"
  alias_method :on_a, :on_b
end
class D
  include Tr
  def on_b = "D#on_b"
end
p D.new.on_a, D.new.on_b
class E
  include Tr
end
p E.new.on_a
module Tr2
  def x = "Tr2#x #{@v}"
  alias y x
end
class F
  include Tr2
  def initialize = @v = 1
  def x = "F#x"
end
p F.new.y

module Tm
  def on_b = "Tm#on_b"
  alias_method :on_a, :on_b
  alias_method :on_c, :on_a
end
module U
  def on_b = "U#on_b"
end
class G
  include Tm
  include U
end
p G.new.on_a, G.new.on_b, G.new.on_c
class Dx
  include Tm
  def on_b = "Dx#on_b(#{on_a})"
end
class Dy < Dx; def on_b = "Dy"; end
p Dx.new.on_b, Dy.new.on_a, Dy.new.on_c
p Dx.new.respond_to?(:on_a), Dx.public_method_defined?(:on_a)
module Cnt
  def tick(n) = n + (@k ||= 0)
  alias_method :tock, :tick
end
class H
  include Cnt
  def initialize = @k = 10
  def tick(n) = -n
end
p H.new.tock(1), H.new.tick(1)

# An alias of an alias names the module's method below both, whichever of
# the names the class overrides; a def after the alias is what a later
# alias names.
module Chain
  def base = "Chain#base"
  alias_method :mid, :base
  alias_method :top, :mid
  def own = "Chain#own"
  alias_method :own, :base
  def own = "Chain#own again"
  alias_method :own_top, :own
end
class ChainD
  include Chain
  def base = "ChainD#base"
  def mid = "ChainD#mid"
  def own = "ChainD#own"
end
class ChainE
  include Chain
  def mid = "ChainE#mid"
end
cd = ChainD.new
p cd.base, cd.mid, cd.top, cd.own, cd.own_top
p ChainE.new.top
