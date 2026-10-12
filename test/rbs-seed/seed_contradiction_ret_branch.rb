# spinel: rbs-seed-contradicted-return
# A seeded return answered by a conditional: each branch returns on its own,
# converted to the declared type, so each is judged on its own. The whole
# conditional's type (the boxed union of its branches) made no claim, and
# the Integer branch reached the C compiler as a `const char *` return.
class SeedRetBranch
  def pick(f) = f ? "s" : 1
end

p SeedRetBranch.new.pick(true)
