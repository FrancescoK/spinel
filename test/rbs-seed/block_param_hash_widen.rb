# A block over a receiver the round has not typed yet must not have its params
# widened to poly. Two user classes define a yielding `each`, which is what
# puts this call in the "receiver could reach a user arm" branch; `flat` is a
# parameter whose type arrives from its call site a round later, so the
# widening was decided on UNKNOWN and never taken back. The String->String
# `scalars` written from the block followed it to poly, and so did the KEY of
# the `out` it was copied into -- and the poly-keyed hash no longer fit the
# RBS-declared Hash[String, untyped] setter, stopping the C build (#4100).
# spinel: rbs-seed-check
module Enum
  class Pair
    def initialize(a, b)
      @a = a
      @b = b
    end
    def each
      yield @a
      yield @b
    end
  end

  class Solo
    def initialize(v)
      @v = v
    end
    def each
      yield @v
    end
  end
end

class Req
  def initialize(rp)
    @rp = rp
  end
  def req_params
    @rp
  end
end

class Env
  def params=(h)
    @params = h
  end
  def params
    @params
  end
end

module Main
  def self.nest(flat)
    scalars = { "seed" => "s" }
    flat.each do |k, v|
      scalars[k] = v
    end
    out = { "n" => 1, "m" => "x" }
    scalars.each { |k, v| out[k] = v }
    out
  end

  def self.run(req)
    env = Env.new
    env.params = nest(req.req_params)
    env
  end
end

e = Main.run(Req.new({ "a" => "b", "c" => "d" }))
p e.params["a"]
p e.params["seed"]
p e.params["n"]

pair = Enum::Pair.new("p", "q")
pair.each { |x| print x }
puts
Enum::Solo.new("r").each { |x| puts x }
