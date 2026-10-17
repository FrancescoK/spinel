# spinel: rbs-seed-contradicted-return
# A seeded return answered through a `begin` with a rescue clause: each branch returns on its
# own, converted to the declared type, so each is judged on its own
# (seed_contradiction_ret_branch.rb). The walk that lists the branches
# stopped at a `begin` with a rescue clause, so the Integer branch of a method declared to
# return a String reached the C compiler as a `const char *` return.
class SeedRetBranchBegin
  def pick(f)
    begin
      raise ArgumentError, 'x' if f
      "s"
    rescue ArgumentError
      1
    end
  end
end

p SeedRetBranchBegin.new.pick(true)
