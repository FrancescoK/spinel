# A method an --rbs signature declares `-> Hash[String, String]?` whose
# body builds a String Hash of Strings it was handed, and answers it
# through `return params` beside a last nil or beside a `return nil`, has
# its seed follow the Hash the body builds: nil is the Hash pointer's NULL
# whatever the Hash's form, so it no longer hides that Hash from the seed
# (whose typed Hash the body's Hash did not fit, and the C did not build).
# The nil such an answer is reads as nil to the class tests (is_a?, case,
# Class ===, equal?), as the Hash pointer's NULL does to nil?. A method whose
# Hash has boxed keys (the keys come from untyped Arrays) gives its seed
# way, and so does the method that answers what it returns.
# spinel: rbs-seed-check
module HntsRouter
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

  def self.first(parts)
    params = {}
    params["id"] = parts[1]
    return params if parts.length == 2
    nil
  end
end

s = +"7"
s << "0"
parts = ["a", s]
p HntsRouter.match_parts(["x", "id"], parts), HntsRouter.match_parts(["x"], parts)
p HntsRouter.first(parts), HntsRouter.first(["q"])

n = HntsRouter.first(["q"])
h = HntsRouter.first(parts)
p n.is_a?(Hash), h.is_a?(Hash), n.nil?, n.equal?(nil), h.equal?(nil), Hash === n, NilClass === n
case n
when nil then puts "nil"
when Hash then puts "hash"
end
case h
when nil then puts "nil"
when Hash then puts "hash"
end
a = [n, h]
p n.equal?(a[0]), h.equal?(a[1]), n.equal?(a[1]), h.equal?(a[0]), n.instance_of?(NilClass), n.kind_of?(Hash)

module HntsBoxed
  def self.match(pat, path)
    return nil if pat.length != path.length
    params = {}
    pat.each_with_index { |k, i| params[k] = path[i] }
    params
  end

  def self.scan(routes, path)
    i = 0
    while i < routes.length
      params = match(routes[i], path)
      return params unless params.nil?
      i += 1
    end
    nil
  end
end
p HntsBoxed.scan([["a"], ["x", "id"]], ["a", "7"]), HntsBoxed.scan([["a"]], ["z", "y"])
p HntsBoxed.match(["x", "id"], ["a", "7"]), HntsBoxed.match(["x"], ["a", "7"])
