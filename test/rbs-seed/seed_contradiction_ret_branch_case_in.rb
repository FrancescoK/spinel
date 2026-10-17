# spinel: rbs-seed-contradicted-return
# A seeded return answered through a `case`/`in`: each branch returns on its
# own, converted to the declared type, so each is judged on its own
# (seed_contradiction_ret_branch.rb). The walk that lists the branches
# stopped at a `case`/`in`, so the Integer branch of a method declared to
# return a String reached the C compiler as a `const char *` return.
class SeedRetBranchCaseIn
  def pick(f)
    case f
    in true then "s"
    else 1
    end
  end
end

p SeedRetBranchCaseIn.new.pick(true)
