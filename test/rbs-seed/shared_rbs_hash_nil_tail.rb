# Under --share-strings (#6765), a method an --rbs signature declares
# `-> Hash[String, String]?` whose Hash holds Strings the rule shares
# answers the String-poly Hash its body builds, also where the body's last
# value is nil beside an explicit `return params`, or where a `return nil`
# stands beside the Hash: nil is the Hash pointer's NULL whatever the
# Hash's form, so it no longer joins the Hash into a plain poly value that
# keeps the seed's typed String Hash, which cannot hold the shared handle.
# The same seed over a body building a String-poly Hash beside a nil
# compiled to C that does not build in the default build. When the Hash has
# boxed keys (they come from untyped Arrays), the seed gives way instead, to
# the poly value the method answers, and the method that answers what it
# returns follows it (its seed had kept the typed Hash and read the poly one
# as that).
# spinel: rbs-seed-check
class ShhnRoute
  attr_reader :parts
  def initialize(parts)
    @parts = parts
  end
end

module ShhnRouter
  def self.match_parts(pattern_parts, path_parts)
    return nil if pattern_parts.length != path_parts.length
    params = {}
    i = 0
    while i < pattern_parts.length
      params[pattern_parts[i]] = path_parts[i]
      i += 1
    end
    params
  end

  def self.scan(routes, path_parts)
    i = 0
    while i < routes.length
      params = match_parts(routes[i].parts, path_parts)
      return params unless params.nil?
      i += 1
    end
    nil
  end

  def self.first(parts)
    params = {}
    params["id"] = parts[1]
    return params if parts.length == 2
    nil
  end
end

routes = [ShhnRoute.new(["a"]), ShhnRoute.new(["x", "id"])]
parts = ["a", +"7"]
h = ShhnRouter.scan(routes, parts)
g = ShhnRouter.first(parts)
m = ShhnRouter.match_parts(["x"], parts)
parts[1] << "0"
p h, g, m, ShhnRouter.scan(routes, ["q", "r", "s"]), ShhnRouter.first(["q"])
p h["id"].equal?(parts[1]), g["id"].equal?(parts[1])

module ShhnBoxed
  def self.match(pat, path)
    return nil if pat.length != path.length
    params = {}
    pat.each_with_index { |k, i| params[k] = path[i] }
    params
  end

  def self.scan(routes, path)
    routes.each do |rt|
      params = match(rt, path)
      next unless params
      return params
    end
    nil
  end
end
bparts = ["a", +"7"]
bh = ShhnBoxed.scan([["a"], ["x", "id"]], bparts)
bn = ShhnBoxed.scan([["a"]], ["z", "y", "w"])
bparts[1] << "0"
bh["x"] = "y"
p bh, bn, bh["id"].equal?(bparts[1])
