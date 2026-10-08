# A definition a later `def` has REPLACED cannot be called: dispatch resolves
# to the last one, and did before the return-seed rule existed. Judging the
# replaced body refused a program spinel compiles and runs correctly (#4024).
# spinel: rbs-seed-run
class Rel
  def initialize(k)
    @k = k
  end

  def to_s
    "rel(" + @k + ")"
  end
end

class Base
  # the fallback definition, replaced below
  def self.all
    ["a", "b"]
  end
end

class Base
  # the reopen every call reaches
  def self.all
    Rel.new("base")
  end
end

puts Base.all.to_s
