# spinel: rbs-seed-run
# A method an --rbs signature gives Array[String] whose literal holds another
# class too (the signature is wrong about it, and CRuby does not check) is
# the general Array by the time the return is settled, and the return follows
# its body: a `return` beside a tail literal, a def's own `rescue` (the scan
# of the method's `return`s read the arguments off the wrong node, and a def
# with a rescue of its own has a `begin` for a body). Only the paths whose
# values the signature describes are run.
module SeedLate
  def self.early(f)
    return [1, "a"] if f == 1
    ["x", "y"]
  end

  def self.own_rescue(f)
    raise "boom" if f == 0
    ["p", "q"]
  rescue
    [3, "r"]
  end

  def self.only(f)
    return [2, "s"]
  end
end
p SeedLate.early(1), SeedLate.early(2)
p SeedLate.own_rescue(1)
p SeedLate.only(1)
