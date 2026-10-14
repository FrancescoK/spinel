# A method an --rbs signature declares `-> Hash[String, String]?` whose
# body builds a String Hash of Strings it was handed, and answers it
# through `return params` beside a last nil or beside a `return nil`, has
# its seed follow the Hash the body builds: nil is the Hash pointer's NULL
# whatever the Hash's form, so it no longer hides that Hash from the seed
# (whose typed Hash the body's Hash did not fit, and the C did not build).
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
