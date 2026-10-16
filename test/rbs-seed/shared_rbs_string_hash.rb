# Under --share-strings (#6765), a Hash[String, String] parameter, return
# or instance variable an --rbs signature types takes the boxed Hash of
# shared handles when the Strings it holds are shared, as an inferred
# String Hash does: the seed says what it holds, Strings, and not how C
# holds them. The rule refused each of these ("a typed String container
# cannot hold the shared handle yet"), and a Rails application's cookie jar,
# router and attribute hashes stopped there.
class ShrbshJar
  def initialize
    @out = {}
    @flags = {}
  end

  def set(k, v)
    @out[k] = v
  end

  def flag(k)
    ss = +"Lax"
    ss << "!" if k == "x"
    @flags[k] = ss
    @out[k] = ss
    @flags
  end

  def pending
    @out
  end
end

module ShrbshRouter
  def self.decode_captures(params)
    decoded = {}
    params.each { |k, v| decoded[k] = v }
    decoded
  end

  def self.captures(path)
    params = {}
    seg = +"id-"
    seg << path
    params["id"] = seg
    decode_captures(params)
  end
end

def shrbsh_merge(base, extra)
  base.merge(extra)
end

j = ShrbshJar.new
s = +"abc"
s << "d"
j.set("a", s)
j.flag("b")
s << "e"
p j.pending
p j.flag("x")
p ShrbshRouter.captures("42")

attrs = {}
v = +"v"
attrs["k"] = v
v << "w"
p shrbsh_merge(attrs, { "z" => "q" })
