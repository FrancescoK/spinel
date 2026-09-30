# attr_reader / attr_writer / attr_accessor / attr answer the Array of the
# method names they define, and define them in a value position too.

class K
  r = attr_reader :q
  p r
  w = attr_writer :q, :s
  p w
  a = attr_accessor :t, :u
  p a
  p(attr_reader :v)
  x = attr :z
  p x
end

module M
  r = attr_accessor :m
  p r
end

class C
  include M
  class << self
    s = attr_accessor :cfg
  end
end

k = K.new
k.t = 3
k.q = 5
p k.t
p k.q
c = C.new
c.m = 4
p c.m
C.cfg = 9
p C.cfg
