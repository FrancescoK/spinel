# spinel: rbs-seed-contradicted-return
# A seeded return answered through a rescue modifier: each branch returns on its
# own, converted to the declared type, so each is judged on its own
# (seed_contradiction_ret_branch.rb). The walk that lists the branches
# stopped at a rescue modifier, so the Integer branch of a method declared to
# return a String reached the C compiler as a `const char *` return.
class SeedRetBranchRescueModifier
  def pick(f)
    (raise ArgumentError, 'x' if f; "s") rescue 1
  end
end

p SeedRetBranchRescueModifier.new.pick(true)
