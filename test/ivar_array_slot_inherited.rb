# An Integer-array ivar shared through inheritance. Under
# --int-overflow=promote `[k]` over a widened parameter is a poly array, and
# the ivar slot it is written to widens with it -- in the class whose method
# writes it and in every class that holds the same field: a subclass's copy
# (an initialize forwarded with super, or inherited outright) and an
# ancestor whose methods read it. A slot left behind as an Integer array was
# refused as a class-layout mismatch. Same answers in every mode.
class N
  def initialize(k) = (@a = [k])
  def a = @a
end

class M < N
  def initialize(k)
    super
    @b = 1
  end
end

class L < N
end

class K < L
  def initialize(k)
    super(k + 1)
    @c = [1, 2]
  end
  def c = @c
end
p M.new(1).a, N.new(2).a, L.new(3).a, K.new(4).a, K.new(5).c

# the subclass writes the slot its ancestor reads
class P
  def v = @v
end

class Q < P
  def initialize(k) = (@v = [k])
end

class R < P
  def initialize = (@v = [1, 2])
end
p Q.new(6).v, R.new.v, P.new.v

# an exception subclass's chain
class E < StandardError
  def initialize(k)
    super("e")
    @w = [k]
  end
  def w = @w
end

class F < E
end
p F.new(7).w, F.new(8).message
