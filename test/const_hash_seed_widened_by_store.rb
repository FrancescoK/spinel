# A Hash a constant or a global is assigned -- a literal, or one a local
# hands over through a `begin` (a String-to-String Hash seeded and emptied)
# -- is built as the Hash the slot's `[]=` stores widen it to. The literal
# kept its String-valued variant: a store of another class raised
# TypeError, and where the slot settled late on the String-keyed poly Hash
# the write was refused ("a constant write given a Hash, which no
# conversion keeps in its sp_StrPolyHash * slot").

class Safe
  def initialize(s) = (@s = s)
  def to_s = @s
end

module Registry
  class Base
    VERSIONS = begin
      h = { "" => "" }
      h.delete("")
      h
    end

    def self.version(v)
      VERSIONS[self.name] = v.to_s
    end

    def self.version_string
      VERSIONS[self.name] || ""
    end
  end
end

class M1 < Registry::Base
  version "20260924"
end
class M2 < Registry::Base
  version Safe.new(7)
end
class M3 < Registry::Base
end
p M1.version_string
p M3.version_string
p Registry::Base::VERSIONS

TABLE = { "" => "" }
def record(name, v) = (TABLE[name] = v)
record("a", "1")
record("b", 2)
p TABLE
p TABLE["b"] + 1

$seen = begin
  s = { "x" => "y" }
  s
end
def note(k, v) = ($seen[k] = v)
note("n", :sym)
note("m", "str")
p $seen
