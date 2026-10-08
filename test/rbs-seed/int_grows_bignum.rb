# An RBS `Integer` covers both machine ints and bignums, so a body whose loop
# grows past sp_int is a valid inhabitant of the declared type. Seeding the
# return pinned the signature to sp_int, and the bignum came back through it
# as a truncated pointer -- declaring the type made the program worse than not
# declaring it (#3518). The seed now lets a bignum body widen it.
# spinel: rbs-seed-check
class Backoff
  def initialize
    @mult = 2
    @base = 100
  end

  def compute(n)
    d = @base
    i = 0
    while i < n
      d = d * @mult
      i = i + 1
    end
    d
  end
end

b = Backoff.new
puts b.compute(3)
puts b.compute(40)
