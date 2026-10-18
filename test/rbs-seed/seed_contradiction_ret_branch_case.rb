# spinel: rbs-seed-contradicted-return
# A seeded return answered through a `case`/`when`: each branch returns on its
# own, converted to the declared type, so each is judged on its own
# (seed_contradiction_ret_branch.rb). The walk that lists the branches
# stopped at a `case`/`when`, so the Integer branch of a method declared to
# return a String reached the C compiler as a `const char *` return.
class SeedRetBranchCase
  def pick(f)
    case f
    when true then "s"
    else 1
    end
  end
end

p SeedRetBranchCase.new.pick(true)
